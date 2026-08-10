import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _authRetryKey = 'examtreeAuthRetried';

bool shouldRetryAuthentication({
  required int? statusCode,
  required bool alreadyRetried,
  required bool hasAuthenticatedUser,
}) {
  return statusCode == 401 && !alreadyRetried && hasAuthenticatedUser;
}

abstract interface class AuthTokenProvider {
  bool get hasAuthenticatedUser;

  Future<String?> getToken({bool forceRefresh = false});
}

class FirebaseAuthTokenProvider implements AuthTokenProvider {
  FirebaseAuthTokenProvider(this._auth);

  final FirebaseAuth _auth;

  @override
  bool get hasAuthenticatedUser => _auth.currentUser != null;

  @override
  Future<String?> getToken({bool forceRefresh = false}) {
    final user = _auth.currentUser;
    if (user == null) return Future<String?>.value();
    return user.getIdToken(forceRefresh);
  }
}

class ApiClient {
  ApiClient({Dio? dio, AuthTokenProvider? authTokenProvider})
      : dio = dio ?? _createBaseDio() {
    _attachInterceptors(
      this.dio,
      authTokenProvider ?? FirebaseAuthTokenProvider(FirebaseAuth.instance),
    );
  }

  final Dio dio;

  static Dio _createBaseDio() {
    return Dio(
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
  }

  static void _attachInterceptors(
    Dio dio,
    AuthTokenProvider authTokenProvider,
  ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!authTokenProvider.hasAuthenticatedUser) {
            return handler.next(options);
          }

          try {
            final idToken = await authTokenProvider.getToken();
            if (idToken != null && idToken.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $idToken';
            }
          } catch (_) {
            // Let the request proceed. A 401 response gets one forced refresh
            // below, while connectivity/token-provider errors stay recoverable.
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final alreadyRetried = request.extra[_authRetryKey] == true;
          if (!shouldRetryAuthentication(
            statusCode: error.response?.statusCode,
            alreadyRetried: alreadyRetried,
            hasAuthenticatedUser: authTokenProvider.hasAuthenticatedUser,
          )) {
            return handler.next(error);
          }

          try {
            final refreshedToken = await authTokenProvider.getToken(
              forceRefresh: true,
            );
            if (refreshedToken == null || refreshedToken.trim().isEmpty) {
              return handler.next(error);
            }

            request.extra[_authRetryKey] = true;
            request.headers['Authorization'] = 'Bearer $refreshedToken';
            final response = await dio.fetch<dynamic>(request);
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.reject(retryError);
          } catch (_) {
            return handler.next(error);
          }
        },
      ),
    );
  }
}
