import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
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
  final RxList<PaymentPlanModel> paymentPlans = <PaymentPlanModel>[].obs;
  final Rxn<PaymentPlanModel> selectedPlan = Rxn<PaymentPlanModel>();

  Future<void> openUnlockProFlow() async {
    await fetchPaymentPlans(showLoading: true);
    if (paymentPlans.isEmpty) return;

    selectedPlan.value =
        paymentPlans.firstWhereOrNull((plan) => plan.isActive) ??
        paymentPlans.first;
    _showPaymentPlanDialog();
  }

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

    if (status == 'COMPLETED' || status == 'ACTIVE') {
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

  String? get _bearerToken {
    final accessToken = StorageService.token;
    return accessToken == null || accessToken.isEmpty
        ? null
        : 'Bearer $accessToken';
  }

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
                'Choose Pro Plan',
                style: getTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 14,
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
