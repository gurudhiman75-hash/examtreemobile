import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  ApiClient({Dio? dio}) : dio = dio ?? _createDio();

  final Dio dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'EXAMTREE_API_BASE_URL',
          defaultValue: 'https://examtree-new.onrender.com/api',
        ),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'x-examtree-device': 'android',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final idToken = await user.getIdToken();
              if (idToken != null) {
                options.headers['Authorization'] = 'Bearer $idToken';
              }
            } catch (e) {
              // Ignore token fetch errors here
            }
          }
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}

