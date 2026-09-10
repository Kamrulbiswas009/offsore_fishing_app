import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/models/response_data.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/payment_service/model/payment_plan_model.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';

class PaymentServiceController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // --- Android / Stripe Payment State ---
  final RxList<PaymentPlanModel> paymentPlans = <PaymentPlanModel>[].obs;
  final Rxn<PaymentPlanModel> selectedPlan = Rxn<PaymentPlanModel>();

  // --- iOS In-App Purchase (IAP) Configuration & State ---
  static const Set<String> _iosProductIds = {
    'com.onthebite.app.premium.monthly',
  };

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _iapSubscription;
  final RxList<ProductDetails> iosProducts = <ProductDetails>[].obs;
  final Rxn<ProductDetails> selectedIosProduct = Rxn<ProductDetails>();

  @override
  void onInit() {
    super.onInit();
    if (Platform.isIOS) {
      _initIapStream();
    }
  }

  void _initIapStream() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _iapSubscription = purchaseUpdated.listen(
      _onPurchaseUpdated,
      onDone: () => _iapSubscription?.cancel(),
      onError: (error) {
        AppLoggerHelper.error('IAP purchase stream error', error);
      },
    );
  }

  @override
  void onClose() {
    _iapSubscription?.cancel();
    super.onClose();
  }

  Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        await EasyLoading.show(status: 'Processing purchase...');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          await EasyLoading.dismiss();
          AppLoggerHelper.error(
            'IAP purchase failed: ${purchaseDetails.error?.message}',
            purchaseDetails.error,
          );
          if (purchaseDetails.error?.code != 'storekit_canceled' &&
              purchaseDetails.error?.code != 'canceled') {
            CommonMessage.showMessage(
              title: 'Purchase Error',
              message:
                  purchaseDetails.error?.message ?? 'Payment was not completed.',
            );
          }
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await EasyLoading.dismiss();
          AppLoggerHelper.info(
            'IAP purchase successful/restored: ${purchaseDetails.productID}',
          );
          await _handleIosPurchaseSuccess(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          await EasyLoading.dismiss();
          AppLoggerHelper.info('IAP purchase canceled.');
        }

        if (purchaseDetails.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchaseDetails);
          } catch (error) {
            AppLoggerHelper.error('Error completing purchase', error);
          }
        }
      }
    }
  }

  Future<void> _handleIosPurchaseSuccess(
    PurchaseDetails purchaseDetails,
  ) async {
    await EasyLoading.show(status: 'Verifying subscription...');
    try {
      final receipt = purchaseDetails.verificationData.serverVerificationData.isNotEmpty
          ? purchaseDetails.verificationData.serverVerificationData
          : purchaseDetails.verificationData.localVerificationData;

      final body = {
        "productId": purchaseDetails.productID,
        "transactionId": purchaseDetails.purchaseID ?? '',
        "receiptData": receipt,
      };

      AppLoggerHelper.info('IAP verification request body: $body');

      final response = await _networkCaller.postRequest(
        ApiConstants.inAppSubscriptionSuccessApi,
        body: body,
        token: _bearerToken,
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'IAP verification API failed: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Subscription Verification Failed',
          message: response.errorMessage,
        );
        return;
      }

      AppLoggerHelper.info(
        'IAP verification API successful, refreshing profile data.',
      );
      await _refetchProfileAfterPayment();
    } catch (error) {
      AppLoggerHelper.error('IAP verification error', error);
      CommonMessage.showMessage(
        title: 'Subscription Error',
        message: 'Could not verify purchase with server.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  // --- Flow Entry Point ---

  Future<void> openUnlockProFlow() async {
    if (Platform.isIOS) {
      await _openIosUnlockProFlow();
      return;
    }

    // Android / Default Stripe Flow
    await fetchPaymentPlans(showLoading: true);
    if (paymentPlans.isEmpty) return;

    selectedPlan.value =
        paymentPlans.firstWhereOrNull((plan) => plan.isActive) ??
        paymentPlans.first;
    _showPaymentPlanDialog();
  }

  // --- iOS IAP Methods ---

  Future<void> _openIosUnlockProFlow() async {
    await EasyLoading.show(status: 'Loading plans...');
    try {
      final isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        await EasyLoading.dismiss();
        CommonMessage.showMessage(
          title: 'In-App Purchase',
          message: 'Store is not available on this device.',
        );
        return;
      }

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_iosProductIds);
      await EasyLoading.dismiss();

      if (response.notFoundIDs.isNotEmpty) {
        AppLoggerHelper.warning(
          'IAP Product IDs not found: ${response.notFoundIDs}',
        );
      }

      if (response.error != null) {
        AppLoggerHelper.error(
          'IAP Product query error: ${response.error?.message}',
        );
        CommonMessage.showMessage(
          title: 'In-App Purchase',
          message: 'Could not load subscription products.',
        );
        return;
      }

      if (response.productDetails.isEmpty) {
        CommonMessage.showMessage(
          title: 'In-App Purchase',
          message: 'No subscription plan is available right now.',
        );
        return;
      }

      iosProducts.assignAll(response.productDetails);
      selectedIosProduct.value = iosProducts.first;

      _showIosPaymentPlanDialog();
    } catch (error) {
      await EasyLoading.dismiss();
      AppLoggerHelper.error('IAP flow threw an error.', error);
      CommonMessage.showMessage(
        title: 'In-App Purchase',
        message: 'Could not initialize subscription flow.',
      );
    }
  }

  Future<void> buyIosProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (error) {
      AppLoggerHelper.error(
        'Failed to initiate purchase for product: ${product.id}',
        error,
      );
      final errorMsg = error.toString();
      if (errorMsg.contains('storekit_duplicate_product_object') ||
          errorMsg.contains('pending transaction')) {
        CommonMessage.showMessage(
          title: 'Pending Transaction',
          message:
              'A transaction for this subscription is already pending in the App Store. Please wait a moment for it to process or tap Restore Purchases.',
        );
      } else {
        CommonMessage.showMessage(
          title: 'Purchase Error',
          message: 'Could not start App Store checkout.',
        );
      }
    }
  }

  Future<void> restoreIosPurchases() async {
    await EasyLoading.show(status: 'Restoring purchases...');
    try {
      await _iap.restorePurchases();
      await EasyLoading.dismiss();
      CommonMessage.showMessage(
        title: 'Restore Purchases',
        message: 'Restore request sent to App Store.',
      );
    } catch (error) {
      await EasyLoading.dismiss();
      AppLoggerHelper.error('Restore purchases error', error);
      CommonMessage.showMessage(
        title: 'Restore Error',
        message: 'Could not restore purchases from App Store.',
      );
    }
  }

  // --- Android / Stripe Methods ---

  Future<void> fetchPaymentPlans({bool showLoading = false}) async {
    if (showLoading) {
      await EasyLoading.show(status: 'Loading plans...');
    }

    try {
      final response = await _networkCaller.getRequest(
        ApiConstants.getPaymentPlanApi,
        token: _bearerToken,
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'Payment plans fetch failed: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Payment plans',
          message: response.errorMessage,
        );
        return;
      }

      final responseBody = response.responseData;
      final data = responseBody is Map ? responseBody['data'] : null;
      if (data is! List) {
        AppLoggerHelper.error('Payment plans response data is invalid.');
        CommonMessage.showMessage(
          title: 'Payment plans',
          message: 'Could not load payment plans.',
        );
        return;
      }

      paymentPlans.assignAll(
        data
            .whereType<Map>()
            .map(
              (item) =>
                  PaymentPlanModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );

      if (paymentPlans.isEmpty) {
        CommonMessage.showMessage(
          title: 'Payment plans',
          message: 'No payment plan is available right now.',
        );
      }
    } catch (error) {
      AppLoggerHelper.error('Payment plans fetch threw an error.', error);
      CommonMessage.showMessage(
        title: 'Payment plans',
        message: 'Could not load payment plans.',
      );
    } finally {
      if (showLoading) {
        await EasyLoading.dismiss();
      }
    }
  }

  Future<void> confirmSelectedPlan() async {
    final plan = selectedPlan.value;
    if (plan == null) {
      CommonMessage.showMessage(
        title: 'Payment plan',
        message: 'Please select a plan first.',
      );
      return;
    }

    Get.back();
    await EasyLoading.show(status: 'Creating payment...');

    try {
      final intentResponse = await _createPaymentIntent(plan.stripePriceId);
      if (!intentResponse.isSuccess) {
        AppLoggerHelper.error(
          'Payment intent create failed: ${intentResponse.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Payment',
          message: intentResponse.errorMessage,
        );
        return;
      }

      final intentData = _intentData(intentResponse);
      final clientSecret = intentData['clientSecret'];
      final publishableKey = intentData['publishableKey'];
      AppLoggerHelper.info(
        'Payment intent created: ${intentData['paymentIntentId'] ?? 'unknown'}',
      );

      if (clientSecret is! String ||
          clientSecret.isEmpty ||
          publishableKey is! String ||
          publishableKey.isEmpty) {
        AppLoggerHelper.error(
          'Payment intent response is missing Stripe data.',
        );
        CommonMessage.showMessage(
          title: 'Payment',
          message: 'Could not start Stripe payment.',
        );
        return;
      }

      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'On The Bite',
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.dark,
        ),
      );

      await EasyLoading.dismiss();
      await Stripe.instance.presentPaymentSheet();

      await _refetchProfileAfterPayment();
    } on StripeException catch (error) {
      AppLoggerHelper.error('Stripe payment failed.', error);
      CommonMessage.showMessage(
        title: 'Payment',
        message: error.error.localizedMessage ?? 'Payment was not completed.',
      );
    } catch (error) {
      AppLoggerHelper.error('Payment flow threw an error.', error);
      CommonMessage.showMessage(
        title: 'Payment',
        message: 'Payment could not be completed.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  Future<ResponseData> _createPaymentIntent(String priceId) {
    return _networkCaller.postRequest(
      ApiConstants.createPaymentIntentPlanApi,
      body: {'priceId': priceId},
      token: _bearerToken,
    );
  }

  Map<dynamic, dynamic> _intentData(ResponseData response) {
    final responseBody = response.responseData;
    final data = responseBody is Map ? responseBody['data'] : null;
    return data is Map ? data : const {};
  }

  Future<void> _refetchProfileAfterPayment() async {
    await EasyLoading.show(status: 'Refreshing profile...');

    final profileController = Get.find<ProfileMainScreenController>();
    await profileController.getAuthMe();

    final subscription = profileController.authMe.value?.subscription;
    final status = subscription?.status.toUpperCase();
    final plan = subscription?.plan.toUpperCase();

    if (plan == 'PRO' && status == 'ACTIVE') {
      CommonMessage.showMessage(
        title: 'Payment success',
        message: 'Your Pro subscription is active.',
      );
      return;
    }

    AppLoggerHelper.info(
      'Payment finished but subscription status is ${subscription?.status ?? 'missing'}.',
    );
    CommonMessage.showMessage(
      title: 'Payment processing',
      message: 'Payment completed. Subscription status is updating.',
    );
  }

  // --- Cancel & Reactivate Actions (Platform Aware) ---

  Future<void> cancelSubscription() async {
    if (Platform.isIOS) {
      await _openAppleSubscriptionManagement();
      return;
    }

    await EasyLoading.show(status: 'Canceling subscription...');
    try {
      final response = await _networkCaller.postRequest(
        ApiConstants.cancelPaymentSubscriptionApi,
        body: {},
        token: _bearerToken,
      );

      await EasyLoading.dismiss();

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'Cancel subscription failed: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Subscription',
          message: response.errorMessage,
        );
        return;
      }

      final responseBody = response.responseData;
      final mainMessage = responseBody is Map
          ? responseBody['message'] as String?
          : null;
      final data = responseBody is Map ? responseBody['data'] : null;
      final dataMessage = data is Map ? data['message'] as String? : null;

      if (mainMessage != null && mainMessage.isNotEmpty) {
        await EasyLoading.showSuccess(mainMessage);
        await Future.delayed(const Duration(seconds: 2));
      }

      if (dataMessage != null && dataMessage.isNotEmpty) {
        await EasyLoading.showInfo(dataMessage);
        await Future.delayed(const Duration(seconds: 2));
      }

      final profileController = Get.find<ProfileMainScreenController>();
      await profileController.getAuthMe();
    } catch (error) {
      await EasyLoading.dismiss();
      AppLoggerHelper.error('Cancel subscription error', error);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Could not cancel subscription. Please try again.',
      );
    }
  }

  Future<void> reactivateSubscription() async {
    if (Platform.isIOS) {
      await restoreIosPurchases();
      return;
    }

    await EasyLoading.show(status: 'Reactivating subscription...');
    try {
      final response = await _networkCaller.postRequest(
        ApiConstants.reActivePaymentSubscriptionApi,
        body: {},
        token: _bearerToken,
      );

      await EasyLoading.dismiss();

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'Reactivate subscription failed: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Subscription',
          message: response.errorMessage,
        );
        return;
      }

      final responseBody = response.responseData;
      final mainMessage = responseBody is Map
          ? responseBody['message'] as String?
          : null;
      final data = responseBody is Map ? responseBody['data'] : null;
      final dataMessage = data is Map ? data['message'] as String? : null;

      if (mainMessage != null && mainMessage.isNotEmpty) {
        await EasyLoading.showSuccess(mainMessage);
        await Future.delayed(const Duration(seconds: 2));
      }

      if (dataMessage != null && dataMessage.isNotEmpty) {
        await EasyLoading.showInfo(dataMessage);
        await Future.delayed(const Duration(seconds: 2));
      }

      final profileController = Get.find<ProfileMainScreenController>();
      await profileController.getAuthMe();
    } catch (error) {
      await EasyLoading.dismiss();
      AppLoggerHelper.error('Reactivate subscription error', error);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Could not reactivate subscription. Please try again.',
      );
    }
  }

  void showCancelSubscriptionDialog() {
    if (Platform.isIOS) {
      _showIosCancelSubscriptionDialog();
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey3A4B62Color.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cancel Subscription',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to cancel your Pro subscription?',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyC8D0DBColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      ontap: Get.back,
                      title: 'No, Keep It',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: AppColors.grey3A4B62Color,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      ontap: () {
                        Get.back();
                        cancelSubscription();
                      },
                      title: 'Yes, Cancel',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: const Color(0xFFFB2C36),
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  void showReactivateSubscriptionDialog() {
    if (Platform.isIOS) {
      _showIosReactivateSubscriptionDialog();
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey3A4B62Color.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reactivate Subscription',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Do you want to renew your Pro subscription?',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyC8D0DBColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      ontap: Get.back,
                      title: 'Cancel',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: AppColors.grey3A4B62Color,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      ontap: () {
                        Get.back();
                        reactivateSubscription();
                      },
                      title: 'Yes, Renew',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: AppColors.orangeColor,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  void _showIosCancelSubscriptionDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey3A4B62Color.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Manage Subscription',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'On iOS, subscriptions are managed directly through your Apple ID settings. Would you like to open Apple Subscription Management?',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyC8D0DBColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      ontap: Get.back,
                      title: 'Cancel',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: AppColors.grey3A4B62Color,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      ontap: () {
                        Get.back();
                        _openAppleSubscriptionManagement();
                      },
                      title: 'Open Settings',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: const Color(0xFFFB2C36),
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  void _showIosReactivateSubscriptionDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey3A4B62Color.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reactivate / Restore',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You can restore your previous Apple In-App Purchases or manage your subscription status in Apple ID settings.',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyC8D0DBColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      ontap: () {
                        Get.back();
                        restoreIosPurchases();
                      },
                      title: 'Restore',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: AppColors.grey3A4B62Color,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      ontap: () {
                        Get.back();
                        _openAppleSubscriptionManagement();
                      },
                      title: 'Manage In Store',
                      fontSize: 14,
                      lineHeight: 12,
                      bgColor: AppColors.orangeColor,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  Future<void> _openAppleSubscriptionManagement() async {
    const urlString = 'https://apps.apple.com/account/subscriptions';
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CommonMessage.showMessage(
          title: 'Manage Subscription',
          message:
              'Please open iOS Settings > Apple ID > Subscriptions to manage your subscription.',
        );
      }
    } catch (error) {
      AppLoggerHelper.error('Error opening subscription settings', error);
      CommonMessage.showMessage(
        title: 'Manage Subscription',
        message:
            'Please open iOS Settings > Apple ID > Subscriptions to manage your subscription.',
      );
    }
  }

  String? get _bearerToken {
    final accessToken = StorageService.token;
    return accessToken == null || accessToken.isEmpty
        ? null
        : 'Bearer $accessToken';
  }

  // --- Dialogs ---

  void _showPaymentPlanDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey3A4B62Color.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Pro Plan ',
                style: getTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 14,
                ),
              ),
              Text(
                'Auto-Renewable, But you can cancel at any time',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 14.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 420.h),
                child: Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    itemCount: paymentPlans.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final plan = paymentPlans[index];
                      return Obx(
                        () => _PaymentPlanTile(
                          plan: plan,
                          isSelected: selectedPlan.value?.id == plan.id,
                          onTap: () => selectedPlan.value = plan,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      ontap: Get.back,
                      title: 'Cancel',
                      fontSize: 15,
                      lineHeight: 12,
                      bgColor: AppColors.grey3A4B62Color,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      ontap: confirmSelectedPlan,
                      title: 'Confirm',
                      fontSize: 15,
                      lineHeight: 12,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  void _showIosPaymentPlanDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.grey3A4B62Color.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Pro Plan',
                style: getTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 14,
                ),
              ),
              Text(
                'Auto-Renewable, cancel anytime in Apple ID Settings',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 14.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 420.h),
                child: Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    itemCount: iosProducts.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final product = iosProducts[index];
                      return Obx(
                        () => _IosPaymentPlanTile(
                          product: product,
                          isSelected:
                              selectedIosProduct.value?.id == product.id,
                          onTap: () => selectedIosProduct.value = product,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      ontap: Get.back,
                      title: 'Cancel',
                      fontSize: 15,
                      lineHeight: 12,
                      bgColor: AppColors.grey3A4B62Color,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      ontap: () {
                        final product = selectedIosProduct.value;
                        if (product == null) {
                          CommonMessage.showMessage(
                            title: 'Payment plan',
                            message: 'Please select a plan first.',
                          );
                          return;
                        }
                        Get.back();
                        buyIosProduct(product);
                      },
                      title: 'Confirm',
                      fontSize: 15,
                      lineHeight: 12,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }
}

class _PaymentPlanTile extends StatelessWidget {
  final PaymentPlanModel plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentPlanTile({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.black0F1E33Color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.orangeColor
                : AppColors.grey3A4B62Color,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.orangeColor
                  : AppColors.greyC8D0DBColor,
              size: 22.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                      lineHeight: 12,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    plan.displayPrice,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blue00D4FFColor,
                      lineHeight: 10,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    plan.description,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyC8D0DBColor,
                      lineHeight: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosPaymentPlanTile extends StatelessWidget {
  final ProductDetails product;
  final bool isSelected;
  final VoidCallback onTap;

  const _IosPaymentPlanTile({
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.black0F1E33Color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.orangeColor
                : AppColors.grey3A4B62Color,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.orangeColor
                  : AppColors.greyC8D0DBColor,
              size: 22.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title.isNotEmpty
                        ? product.title
                        : 'Pro Plan (Monthly)',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                      lineHeight: 12,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    product.price,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blue00D4FFColor,
                      lineHeight: 10,
                    ),
                  ),
                  if (product.description.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      product.description,
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyC8D0DBColor,
                        lineHeight: 9,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
