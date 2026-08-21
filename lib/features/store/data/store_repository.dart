import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/store_product.dart';

class StoreCatalogException implements Exception {
  const StoreCatalogException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class StoreRepository {
  StoreRepository(this._client);

  final ApiClient _client;

  Future<List<StoreProduct>> loadProducts() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/commerce/products',
      );
      final raw = response.data?['products'];
      if (raw is! List) return const [];

      final products = <StoreProduct>[];
      for (final item in raw.whereType<Map>()) {
        try {
          products.add(
            StoreProduct.fromJson(Map<String, dynamic>.from(item)),
          );
        } on FormatException {
          // One malformed commerce row must not hide the remaining catalogue.
        }
      }
      return products;
    } on DioException catch (error) {
      final body = error.response?.data;
      final data = body is Map
          ? Map<String, dynamic>.from(body)
          : const <String, dynamic>{};
      throw StoreCatalogException(
        data['error']?.toString().trim().isNotEmpty == true
            ? data['error'].toString().trim()
            : 'Unable to load the store catalogue.',
        statusCode: error.response?.statusCode,
        code: data['code']?.toString(),
      );
    } catch (_) {
      throw const StoreCatalogException(
        'Unable to load the store catalogue.',
      );
    }
  }
}
