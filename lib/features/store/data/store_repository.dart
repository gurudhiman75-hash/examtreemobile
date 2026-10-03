import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/store_product.dart';
import '../domain/series_purchase.dart';

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
  Future<CouponQuote> validateCoupon({
    required String productId,
    required String couponCode,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/commerce/coupons/validate',
        data: {
          'productId': productId,
          'couponCode': couponCode.trim(),
        },
      );
      return CouponQuote.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _checkoutException(
        error,
        fallback: 'Unable to validate this coupon.',
      );
    }
  }

  Future<CheckoutOrder> createOrder({
    required String productId,
    required String idempotencyKey,
    String? couponCode,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/commerce/orders',
        data: {
          'productId': productId,
          'idempotencyKey': idempotencyKey,
          if (couponCode != null && couponCode.trim().isNotEmpty)
            'couponCode': couponCode.trim(),
        },
      );
      final order = CheckoutOrder.fromJson(response.data ?? const {});
      if (order.orderId.isEmpty ||
          order.providerOrderId.isEmpty ||
          order.keyId.isEmpty) {
        throw const StoreCatalogException(
          'Payment order could not be created.',
          code: 'PAYMENT_ORDER_INVALID',
        );
      }
      return order;
    } on DioException catch (error) {
      throw _checkoutException(
        error,
        fallback: 'Unable to start payment.',
      );
    }
  }

  Future<PaymentConfirmation> confirmOrder({
    required String orderId,
    required String providerPaymentId,
    required String providerSignature,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/commerce/orders/${Uri.encodeComponent(orderId)}/confirm',
        data: {
          'providerPaymentId': providerPaymentId,
          'providerSignature': providerSignature,
        },
      );
      return PaymentConfirmation.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw _checkoutException(
        error,
        fallback: 'Unable to confirm payment.',
      );
    }
  }

  StoreCatalogException _checkoutException(
    DioException error, {
    required String fallback,
  }) {
    final body = error.response?.data;
    final data = body is Map
        ? Map<String, dynamic>.from(body)
        : const <String, dynamic>{};
    return StoreCatalogException(
      data['error']?.toString().trim().isNotEmpty == true
          ? data['error'].toString().trim()
          : fallback,
      statusCode: error.response?.statusCode,
      code: data['code']?.toString(),
    );
  }

}
