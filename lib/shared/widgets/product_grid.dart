import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../shared/models/product.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    this.category,
    this.search,
    this.onTapProduct,
  });

  final String? category;
  final String? search;
  final void Function(Product product)? onTapProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider(
      ProductsFilter(category: category, search: search),
    ));

    return productsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text('Gagal memuat')),
      data: (products) => products.isEmpty
          ? Center(
              child: Text(
                'Produk tidak ditemukan',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) {
                return ProductCard(
                  product: products[i],
                  onTap: onTapProduct != null ? () => onTapProduct!(products[i]) : null,
                );
              },
            ),
    );
  }
}

@immutable
class ProductsFilter {
  const ProductsFilter({this.category, this.search});
  final String? category;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is ProductsFilter &&
      other.category == category &&
      other.search == search;

  @override
  int get hashCode => Object.hash(category, search);
}

final productsProvider = FutureProvider.family<List<Product>, ProductsFilter>((ref, filter) async {
  final api = ref.watch(apiClientProvider);
  final result = await api.listProducts(
    page: 1,
    limit: 40,
    category: filter.category,
    search: filter.search,
  );
  return result.items;
});
