import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';

import '../models/response_data.dart';

class NetworkCaller {
  final int timeoutDuration = 30;

  // GET method
  Future<ResponseData> getRequest(String url, {String? token}) async {
    log('GET Request: $url');
    log('GET Token: ${token == null || token.isEmpty ? '[MISSING]' : '[PRESENT]'}');
    try {
      final Response response = await get(
        Uri.parse(url),
        headers: {
          'Authorization': token.toString(),
          'Content-type': 'application/json',
        },
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST method
  Future<ResponseData> postRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('POST Request: $url');
    log('Request Body: ${jsonEncode(_redactSensitiveData(body))}');

    try {
      final Response response = await post(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': token,
        },
        body: jsonEncode(body),
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PATCH multipart/form-data method (for file uploads)
  Future<ResponseData> patchMultipartRequest(
    String url, {
    Map<String, String>? fields,
    File? file,
    String fileFieldName = 'file',
    String? token,
  }) async {
    log('PATCH Multipart Request: $url');
    try {
      final request = MultipartRequest('PATCH', Uri.parse(url));

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = token;
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (file != null) {
        final mimeType = _guessMimeType(file.path);
        request.files.add(
          await MultipartFile.fromPath(
            fileFieldName,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        Duration(seconds: timeoutDuration),
      );
      final response = await Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  String _guessMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  // Handle response
  ResponseData _handleResponse(Response response) {
    log('Response Status: ${response.statusCode}');
    final decodedResponse = jsonDecode(response.body);
    log('Response Body: ${jsonEncode(_redactSensitiveData(decodedResponse))}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ResponseData(
        isSuccess: true,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: '',
      );
    } else if (response.statusCode == 400) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: _extractErrorMessages(
          decodedResponse['errorSources'],
          fallback: decodedResponse['message'],
        ),
      );
    } else if (response.statusCode == 500) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: '',
        errorMessage:
            decodedResponse['message'] ?? 'An unexpected error occurred!',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: decodedResponse['message'] ?? 'An unknown error occurred',
      );
    }
  }

  // Extract error messages for status 400
  String _extractErrorMessages(dynamic errorSources, {dynamic fallback}) {
    if (errorSources is List) {
      return errorSources
          .map((error) => error['message'] ?? 'Unknown error')
          .join(', ');
    }
    return fallback is String ? fallback : 'Validation error';
  }

  dynamic _redactSensitiveData(dynamic value) {
    if (value is Map) {
      return value.map((key, item) {
        final normalizedKey = key.toString().toLowerCase();
        final isSensitive =
            normalizedKey == 'password' ||
            normalizedKey == 'otp' ||
            normalizedKey == 'accesstoken' ||
            normalizedKey == 'refreshtoken';
        return MapEntry(
          key,
          isSensitive ? '[REDACTED]' : _redactSensitiveData(item),
        );
      });
    }
    if (value is List) return value.map(_redactSensitiveData).toList();
    return value;
  }

  // Handle errors
  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');

    if (error is ClientException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Network error occurred. Please check your connection.',
      );
    } else if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        responseData: '',
        errorMessage: 'Request timeout. Please try again later.',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Unexpected error occurred.',
      );
    }
  }
}
