import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/services/firebase/notification_service.dart';

class AppHelperFunctions{
 AppHelperFunctions._();

 static Future<void> sendLocalNotification({
  required String title,
  required String body,
  String? payload,
  String? imageUrl,
 }) async {
  await NotificationService.sendLocalNotification(
   title: title,
   body: body,
   payload: payload,
   imageUrl: imageUrl,
  );
 }

 static void showSnackBar(String message) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
   SnackBar(content: Text(message)),
  );
 }

 static void showAlert(String title, String message) {
  showDialog(
   context: Get.context!,
   builder: (BuildContext context) {
    return AlertDialog(
     title: Text(title),
     content: Text(message),
     actions: [
      TextButton(
       onPressed: () => Navigator.of(context).pop(),
       child: const Text('OK'),
      ),
     ],
    );
   },
  );
 }

 static void navigateToScreen(BuildContext context, Widget screen) {
  Navigator.push(
   context,
   MaterialPageRoute(builder: (_) => screen),
  );
 }

 static String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) {
   return text;
  } else {
   return '${text.substring(0, maxLength)}...';
  }
 }

 static bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
 }
 static Size screenSize() {
  return MediaQuery.of(Get.context!).size;
 }

 static double screenHeight() {
  return MediaQuery.of(Get.context!).size.height;
 }
 static double screenWidth() {
  return MediaQuery.of(Get.context!).size.width;
 }

 static String getFormattedDate(DateTime date, {String format = 'dd MMM yyyy'}) {
  return DateFormat(format).format(date);
 }

 static List<T> removeDuplicates<T>(List<T> list) {
  return list.toSet().toList();
 }

 static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
  final wrappedList = <Widget>[];
  for (var i = 0; i < widgets.length; i += rowSize) {
   final rowChildren = widgets.sublist(
    i,
    i + rowSize > widgets.length ? widgets.length : i + rowSize,
   );
   wrappedList.add(Row(children: rowChildren));
  }
  return wrappedList;
 }

 static List<double> shiftHistogramToLocal(List<dynamic>? utcHistogram) {
   final localHistogram = List<double>.filled(24, 0.0);
   if (utcHistogram == null || utcHistogram.isEmpty) {
     return localHistogram;
   }
   final offsetHours = DateTime.now().timeZoneOffset.inHours;
   for (int i = 0; i < 24; i++) {
     if (i < utcHistogram.length) {
       int localHour = (i + offsetHours) % 24;
       if (localHour < 0) localHour += 24;
       final val = utcHistogram[i];
       localHistogram[localHour] = val is num ? val.toDouble() : 0.0;
     }
   }
   return localHistogram;
 }

 static String calculateLocalPeakWindowFromLocal(List<double> localHistogram) {
   double totalReports = localHistogram.fold(0.0, (sum, val) => sum + val);
   if (totalReports == 0.0) return "N/A";

   double max4Count = -1.0;
   int peakStartHour = 6;
   for (int i = 0; i < 24; i++) {
     double count = localHistogram[i] +
         localHistogram[(i + 1) % 24] +
         localHistogram[(i + 2) % 24] +
         localHistogram[(i + 3) % 24];
     if (count > max4Count) {
       max4Count = count;
       peakStartHour = i;
     }
   }

   String formatHour(int h) {
     final ampm = h >= 12 ? 'PM' : 'AM';
     final hr = h % 12 == 0 ? 12 : h % 12;
     return "$hr:00 $ampm";
   }
   int peakEndHour = (peakStartHour + 4) % 24;
   return "${formatHour(peakStartHour)} - ${formatHour(peakEndHour)}";
 }
}