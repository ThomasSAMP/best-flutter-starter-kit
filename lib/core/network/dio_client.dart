import 'package:dio/dio.dart';

import '../utils/logger.dart';

class DioClient {
  static Dio createDio({required String baseUrl, required bool enableLogging}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => AppLogger.debug(object),
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token or other headers here if needed
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle errors globally
          AppLogger.error('DioError: ${e.message}', e, e.stackTrace);
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
