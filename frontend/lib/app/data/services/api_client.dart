import 'dart:io';
import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  static const int defaultPort = 1734;

  static String get defaultBaseUrl {
    // 依執行平台自動適配 localhost 與 Android 模擬器 10.0.2.2
    if (!Platform.isAndroid) {
      return 'http://localhost:$defaultPort';
    }
    return 'http://10.0.2.2:$defaultPort';
  }

  static Dio createDio({
    String? baseUrl,
    TokenProvider? tokenProvider,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? defaultBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (tokenProvider != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await tokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            // 遵循驗收標準場景 3: 攔截 401 Unauthorized
            if (e.response?.statusCode == 401) {
              // 由 Controller 或 Global 監聽處理登出轉導
            }
            return handler.next(e);
          },
        ),
      );
    }

    return dio;
  }
}
