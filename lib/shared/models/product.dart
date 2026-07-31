import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.supplyPrice,
    this.cashbackPercentage,
    this.referralPercentage,
    this.stock = 0,
    this.categoryId,
    this.supplierId,
    this.isActive = true,
    this.weightGram,
    this.images,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final int price;
  final int? supplyPrice;
  final double? cashbackPercentage;
  final double? referralPercentage;
  final int stock;
  final String? categoryId;
  final String? supplierId;
  final bool isActive;
  final int? weightGram;
  final List<String>? images;

  bool get inStock => stock > 0;
  String get priceLabel => _formatRp(price);
  String? get imageUrl => (images != null && images!.isNotEmpty) ? images!.first : null;

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    List<String>? images;
    if (imagesRaw is List) {
      images = imagesRaw.map((e) => e.toString()).toList();
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: _asInt(json['price']),
      supplyPrice: json['supply_price'] != null ? _asInt(json['supply_price']) : null,
      cashbackPercentage: _asDouble(json['cashback_percentage']),
      referralPercentage: _asDouble(json['referral_percentage']),
      stock: _asInt(json['stock']),
      categoryId: json['category_id']?.toString(),
      supplierId: json['supplier_id']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      weightGram: json['weight_gram'] != null ? _asInt(json['weight_gram']) : null,
      images: images,
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static String _formatRp(int amount) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return f.format(amount);
  }

  @override
  List<Object?> get props => [id, name, slug, price, stock];
}

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, slug];
}

class PageMeta extends Equatable {
  const PageMeta({
    this.page = 1,
    this.limit = 20,
    this.totalItems = 0,
    this.totalPages = 0,
  });

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  factory PageMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PageMeta();
    return PageMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [page, limit, totalItems, totalPages];
}

class PagedResult<T> extends Equatable {
  const PagedResult({
    required this.items,
    required this.meta,
  });

  final List<T> items;
  final PageMeta meta;

  @override
  List<Object?> get props => [items, meta];
}
