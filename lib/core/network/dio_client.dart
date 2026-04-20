import "package:dio/dio.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final baseUrl =
        dotenv.env["OPENAI_BASE_URL"] ?? "https://api.openai.com/v1";
    final apiKey = dotenv.env["OPENAI_API_KEY"] ?? "";

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
      ),
    );

    // Rate limit retry interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 429) {
            await Future.delayed(const Duration(seconds: 3));
            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Separate Dio instance for Dictionary API (no auth headers)
  static Dio get dictionaryInstance {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );
  }
}
