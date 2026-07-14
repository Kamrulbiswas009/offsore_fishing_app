import 'package:get/get.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';

class ReportDetailsController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  var isLoading = false.obs;
  var errorMessage = "".obs;
  var reportData = Rxn<Map<String, dynamic>>();

  // Fallbacks if API data isn't fetched
  String fallbackZone = "Z1";
  List<Map<String, String>> fallbackSpeciesList = [
    {"name": "Tuna", "qty": "3"},
    {"name": "Mahi", "qty": "2"},
  ];
  String fallbackDepth = "120 ft";
  String fallbackPosition = "Suspended";
  String fallbackMethod = "Trolling";
  String fallbackBait = "Ballyhoo";
  String fallbackTime = "10:30 AM";

  String? reportId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    
    // Parse arguments fallback
    fallbackZone = args?['zone'] ?? "Z1";
    final List<dynamic>? speciesListArg = args?['speciesList'] as List<dynamic>?;
    if (speciesListArg != null) {
      fallbackSpeciesList = speciesListArg.map((e) => Map<String, String>.from(e as Map)).toList();
    }
    fallbackDepth = args?['depth'] ?? "120 ft";
    fallbackPosition = args?['position'] ?? "Suspended";
    fallbackMethod = args?['method'] ?? "Trolling";
    fallbackBait = args?['bait'] ?? "Ballyhoo";
    fallbackTime = args?['time'] ?? "10:30 AM";

    reportId = args?['reportId'];
    if (reportId != null && reportId!.isNotEmpty) {
      fetchReportDetails(reportId!);
    } else {
      AppLoggerHelper.info("ReportDetailsController: No reportId provided, using fallback data.");
    }
  }

  Future<void> fetchReportDetails(String id) async {
    isLoading.value = true;
    errorMessage.value = "";
    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final url = ApiConstants.getSingleReportDetailsApi(id);
      AppLoggerHelper.info("Fetching report details from $url");

      final response = await _networkCaller.getRequest(url, token: token);

      if (response.isSuccess) {
        final body = response.responseData;
        if (body is Map && body['data'] is Map) {
          reportData.value = Map<String, dynamic>.from(body['data']);
          AppLoggerHelper.info("Successfully fetched report details for ID: $id");
        } else {
          errorMessage.value = "Invalid response format";
          AppLoggerHelper.error("Invalid response body format: $body");
        }
      } else {
        errorMessage.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : "Failed to fetch report details";
        AppLoggerHelper.error("Failed to fetch report details: ${response.errorMessage}");
      }
    } catch (e) {
      errorMessage.value = "An error occurred while loading details";
      AppLoggerHelper.error("Exception fetching report details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String get username {
    try {
      final profileController = Get.find<ProfileMainScreenController>();
      final name = profileController.profileName;
      if (name.isNotEmpty && name != 'Captain Mike') {
        return name;
      }
    } catch (_) {}
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['username'] ?? "CaptJohn_87";
  }
}
