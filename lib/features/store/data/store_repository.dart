import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_failure_guidance.dart';
import '../domain/store_checkout.dart';
import '../domain/store_product.dart';

class StoreCatalogException implements Exception {
  const StoreCatalogException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class StoreCheckoutException implements Exception {
  const StoreCheckoutException(this.message, {this.statusCode, this.code});

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
      final data = _responseData(error);
      final guidance = networkFailureGuidance(
        error,
        fallbackTitle: 'Unable to load the store catalogue',
      );
      throw StoreCatalogException(
        guidance.combinedMessage,
        statusCode: error.response?.statusCode,
        code: data['code']?.toString(),
      );
    } catch (_) {
      throw const StoreCatalogException(
        'Unable to load the store catalogue. Please try again.',
      );
    }
  }

  Future<StoreCheckoutOrder> createCheckoutOrder({
    required String productId,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/commerce/orders',
        data: {
          'productId': productId,
          'idempotencyKey': idempotencyKey,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const FormatException('Missing checkout response');
      }
      return StoreCheckoutOrder.fromJson(data);
    } on DioException catch (error) {
      final data = _responseData(error);
      final code = data['code']?.toString();
      throw StoreCheckoutException(
        _checkoutMessage(error, code),
        statusCode: error.response?.statusCode,
        code: code,
      );
    } on FormatException {
      throw const StoreCheckoutException(
        'Payment could not be started safely. Please try again.',
      );
    } catch (_) {
      throw const StoreCheckoutException(
        'Payment could not be started. Please try again.',
      );
    }
  }
}

Map<String, dynamic> _responseData(DioException error) {
  final body = error.response?.data;
  return body is Map
      ? Map<String, dynamic>.from(body)
      : const <String, dynamic>{};
}

String _checkoutMessage(DioException error, String? code) {
  switch (code) {
    case 'STUDENT_IDENTITY_REQUIRED':
      return 'Complete your ExamTree student profile before purchasing a package.';
    case 'PRODUCT_NOT_AVAILABLE':
    case 'SALE_NOT_STARTED':
    case 'SALE_ENDED':
      return 'This package is not available for purchase right now.';
    case 'PAYMENT_PROVIDER_NOT_CONFIGURED':
      return 'Online payment is temporarily unavailable. Please try again later.';
  }

  return networkFailureGuidance(
    error,
    fallbackTitle: 'Payment could not be started',
  ).combinedMessage;
}
