import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:examtree/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _AnonymousTokenProvider implements AuthTokenProvider {
  @override
  bool get hasAuthenticatedUser => false;

  @override
  Future<String?> getToken({bool forceRefresh = false}) async => null;
}

class _CapturingAdapter implements HttpClientAdapter {
  Uri? lastUri;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastUri = options.uri;
    return ResponseBody.fromString(
      '[]',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('Dio transport sends leading-slash repository paths inside /api/', () async {
    final dio = Dio(
      BaseOptions(baseUrl: 'https://examtree-new.onrender.com/api'),
    );
    final adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;
    final client = ApiClient(
      dio: dio,
      authTokenProvider: _AnonymousTokenProvider(),
    );

    await client.dio.get<List<dynamic>>('/tests');

    expect(
      adapter.lastUri,
      Uri.parse('https://examtree-new.onrender.com/api/tests'),
    );
    expect(client.dio.options.baseUrl, 'https://examtree-new.onrender.com/api/');
  });
}
