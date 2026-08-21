import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/store_repository.dart';
import '../../domain/store_product.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository(ref.watch(apiClientProvider));
});

final storeProductsProvider = FutureProvider<List<StoreProduct>>((ref) {
  return ref.watch(storeRepositoryProvider).loadProducts();
});
