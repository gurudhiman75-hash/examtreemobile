import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({Dio? dio}) : dio = dio ?? _createDio();

  final Dio dio;

  static Dio _createDio() {
    const authToken = String.fromEnvironment('EXAMTREE_AUTH_TOKEN');
    final dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'EXAMTREE_API_BASE_URL',
          defaultValue: 'http://10.0.2.2:3000/api',
        ),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'x-examtree-device': 'android',
        },
      ),
    );

    if (authToken.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $authToken';
    }

    return dio;
  }
}
