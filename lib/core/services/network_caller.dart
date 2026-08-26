import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, MultipartFile;
import 'package:http/http.dart';

import '../models/response_data.dart';
import 'offline_cache_service.dart';
import 'sync_service.dart';

class NetworkCaller {
  final int timeoutDuration = 30;

  // Static map to keep track of active, in-flight GET requests to prevent duplicate network traffic
  static final Map<String, Future<ResponseData>> _inFlightRequests = {};

  // Concurrency control / serialization queue to manage traffic and prevent 429 Too Many Requests
  static int _activeRequests = 0;
  static const int _maxConcurrentRequests = 4;
  static final List<Completer<void>> _requestQueue = [];
  static DateTime _lastRequestDispatchTime = DateTime.now();

  static Future<void> _acquireSlot() async {
    if (_activeRequests < _maxConcurrentRequests) {
      _activeRequests++;
      // Subtle inter-request pacing (40ms) to prevent TCP packet collisions on burst
      final now = DateTime.now();
      final diff = now.difference(_lastRequestDispatchTime).inMilliseconds;
      if (diff < 40) {
        await Future.delayed(Duration(milliseconds: 40 - diff));
      }
      _lastRequestDispatchTime = DateTime.now();
      return;
    }

    final completer = Completer<void>();
    _requestQueue.add(completer);
    await completer.future;

    final now = DateTime.now();
    final diff = now.difference(_lastRequestDispatchTime).inMilliseconds;
    if (diff < 40) {
      await Future.delayed(Duration(milliseconds: 40 - diff));
    }
    _lastRequestDispatchTime = DateTime.now();
  }

  static void _releaseSlot() {
    if (_requestQueue.isNotEmpty) {
      final next = _requestQueue.removeAt(0);
      next.complete();
    } else {
      if (_activeRequests > 0) {
        _activeRequests--;
      }
    }
  }

  // Wrapper that handles slot acquisition, retry on 429 / 408 / timeouts, and slot release
  Future<ResponseData> _executeWithTrafficControl(
    Future<ResponseData> Function() requestFn, {
    int maxRetries = 2,
    String? url,
  }) async {
    int attempt = 0;

    while (true) {
      attempt++;
      await _acquireSlot();

      ResponseData? response;
      dynamic caughtException;

      try {
        response = await requestFn();
      } catch (e) {
        caughtException = e;
      } finally {
        _releaseSlot();
      }

      // If we caught a network exception (TimeoutException, SocketException, ClientException)
      if (caughtException != null) {
        final isRetryableException = caughtException is TimeoutException ||
            caughtException is SocketException ||
            caughtException is ClientException;

        if (isRetryableException && attempt <= maxRetries) {
          final backoffMs = (math.pow(2, attempt) * 500 + math.Random().nextInt(300)).toInt();
          debugPrint('[NetworkCaller] Transient exception on $url: $caughtException. Retrying in ${backoffMs}ms (Attempt $attempt of $maxRetries)...');
          await Future.delayed(Duration(milliseconds: backoffMs));
          continue;
        }
        return _handleError(caughtException);
      }

      if (response != null) {
        // If HTTP 429 (Too Many Requests) or HTTP 408 (Request Timeout)
        if ((response.statusCode == 429 || response.statusCode == 408) && attempt <= maxRetries) {
          final backoffMs = (math.pow(2, attempt) * 1000 + math.Random().nextInt(500)).toInt();
          debugPrint('[NetworkCaller] Rate limited / timeout (HTTP ${response.statusCode}) on $url. Retrying in ${backoffMs}ms (Attempt $attempt of $maxRetries)...');
          await Future.delayed(Duration(milliseconds: backoffMs));
          continue;
        }
        return response;
      }

      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'An unexpected request error occurred.',
      );
    }
  }

  // GET method
  Future<ResponseData> getRequest(String url, {String? token}) async {
    final String requestKey = 'GET:$url|Token:${token ?? ""}';

    if (_inFlightRequests.containsKey(requestKey)) {
      log('Coalescing duplicate concurrent GET request for: $url');
      return _inFlightRequests[requestKey]!;
    }

    final Future<ResponseData> future = _executeWithTrafficControl(
      () => _executeGetRequest(url, token),
      url: url,
    );
    _inFlightRequests[requestKey] = future;

    try {
      return await future;
    } finally {
      _inFlightRequests.remove(requestKey);
    }
  }

  Future<ResponseData> _executeGetRequest(String url, String? token) async {
    log('GET Request: $url');
    log(
      'GET Token: ${token == null || token.isEmpty ? '[MISSING]' : '[PRESENT]'}',
    );
    try {
      final Response response = await get(
        Uri.parse(url),
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': token,
          'Content-type': 'application/json',
        },
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // GET with Offline Caching fallback
  Future<ResponseData> cachedGetRequest(
    String url, {
    String? token,
    required String cacheKey,
    int ttlMinutes = 1440,
    Duration? onlineCacheMaxAge = const Duration(seconds: 30),
    bool forceRefresh = false,
  }) async {
    // Check if device is online according to SyncService
    bool isOnline = true;
    try {
      isOnline = Get.find<SyncService>().isOnline.value;
    } catch (_) {}

    // Check online cache first if we have onlineCacheMaxAge and we are online and not forcing refresh
    if (isOnline && !forceRefresh && onlineCacheMaxAge != null) {
      try {
        final cacheService = Get.find<OfflineCacheService>();
        final cachedData = await cacheService.getCache(
          cacheKey,
          ignoreExpiry: false,
          maxAge: onlineCacheMaxAge,
        );
        if (cachedData != null) {
          log('Returning unexpired online cached data for key: $cacheKey');
          return ResponseData(
            isSuccess: true,
            statusCode: 200,
            errorMessage: '',
            responseData: cachedData,
            isFromCache: true,
          );
        }
      } catch (e) {
        log('Failed to read from cache in online cache check: $e');
      }
    }

    if (!isOnline) {
      try {
        final cacheService = Get.find<OfflineCacheService>();
        final cachedData = await cacheService.getCache(
          cacheKey,
          ignoreExpiry: true,
        );
        if (cachedData != null) {
          log(
            'Returning cached fallback data for key: $cacheKey (offline mode)',
          );
          return ResponseData(
            isSuccess: true,
            statusCode: 200,
            errorMessage: '',
            responseData: cachedData,
            isFromCache: true,
          );
        }
      } catch (e) {
        log('Failed to read from cache in offline check: $e');
      }
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Network error occurred. Device is offline.',
        responseData: '',
      );
    }

    // 1. Try request first
    final response = await getRequest(url, token: token);
    if (response.isSuccess) {
      // Save cache
      try {
        final cacheService = Get.find<OfflineCacheService>();
        await cacheService.saveCache(
          cacheKey,
          response.responseData,
          ttlMinutes: ttlMinutes,
        );
      } catch (e) {
        log('Failed to save to cache: $e');
      }
      return response;
    } else {
      // 2. Fallback to cache if failure (timeout, server error, etc.)
      try {
        final cacheService = Get.find<OfflineCacheService>();
        final cachedData = await cacheService.getCache(
          cacheKey,
          ignoreExpiry: true,
        );
        if (cachedData != null) {
          log('Returning cached fallback data for key: $cacheKey');
          return ResponseData(
            isSuccess: true,
            statusCode: 200,
            errorMessage: '',
            responseData: cachedData,
            isFromCache: true,
          );
        }
      } catch (e) {
        log('Failed to read from cache: $e');
      }
      // Return original error if cache miss or error
      return response;
    }
  }

  // DELETE method
  Future<ResponseData> deleteRequest(String url, {String? token}) async {
    return _executeWithTrafficControl(() async {
      log('DELETE Request: $url');
      log(
        'DELETE Token: ${token == null || token.isEmpty ? '[MISSING]' : '[PRESENT]'}',
      );
      final Response response = await delete(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': token,
        },
      ).timeout(Duration(seconds: timeoutDuration));

      return _handleResponse(response);
    }, url: url);
  }

  // POST method
  Future<ResponseData> postRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _executeWithTrafficControl(() async {
      log('POST Request: $url');
      log(
        'Request Body: ${body != null ? jsonEncode(_redactSensitiveData(body)) : 'EMPTY'}',
      );

      final Response response = await post(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': token,
        },
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    }, url: url);
  }

  // PATCH method
  Future<ResponseData> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _executeWithTrafficControl(() async {
      log('PATCH Request: $url');
      log(
        'Request Body: ${body != null ? jsonEncode(_redactSensitiveData(body)) : 'EMPTY'}',
      );

      final Response response = await patch(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': token,
        },
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    }, url: url);
  }

  // PUT method
  Future<ResponseData> putRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    return _executeWithTrafficControl(() async {
      log('PUT Request: $url');
      log(
        'Request Body: ${body != null ? jsonEncode(_redactSensitiveData(body)) : 'EMPTY'}',
      );

      final Response response = await put(
        Uri.parse(url),
        headers: {
          'Content-type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': token,
        },
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    }, url: url);
  }

  // PATCH multipart/form-data method (for file uploads)
  Future<ResponseData> patchMultipartRequest(
    String url, {
    Map<String, String>? fields,
    File? file,
    String fileFieldName = 'file',
    String? token,
  }) async {
    return _executeWithTrafficControl(() async {
      log('PATCH Multipart Request: $url');
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
    }, url: url);
  }

  // POST multipart/form-data method (for file uploads)
  Future<ResponseData> postMultipartRequest(
    String url, {
    Map<String, String>? fields,
    File? file,
    String fileFieldName = 'file',
    String? token,
  }) async {
    return _executeWithTrafficControl(() async {
      log('POST Multipart Request: $url');
      final request = MultipartRequest('POST', Uri.parse(url));

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
    }, url: url);
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

    dynamic decodedResponse;
    bool isJson = false;

    try {
      if (response.body.isNotEmpty) {
        decodedResponse = jsonDecode(response.body);
        isJson = true;
        log(
          'Response Body: ${jsonEncode(_redactSensitiveData(decodedResponse))}',
        );
      } else {
        decodedResponse = '';
      }
    } catch (e) {
      log('Failed to decode JSON response: $e');
      decodedResponse = response.body;
    }

    final bool isMap = isJson && decodedResponse is Map;

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
        errorMessage: isMap
            ? _extractErrorMessages(
                decodedResponse['errorSources'],
                fallback: decodedResponse['message'],
              )
            : 'Validation error',
      );
    } else if (response.statusCode == 500) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: '',
        errorMessage: isMap && decodedResponse['message'] != null
            ? decodedResponse['message']
            : 'An unexpected error occurred!',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: isMap && decodedResponse['message'] != null
            ? decodedResponse['message']
            : (decodedResponse is String && decodedResponse.isNotEmpty
                  ? decodedResponse
                  : 'An unknown error occurred'),
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
            normalizedKey == 'idtoken' ||
            normalizedKey == 'fcmtoken' ||
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
