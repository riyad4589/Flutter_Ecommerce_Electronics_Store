import '../../domain/entities/product.dart';

class ProductModel extends Product {
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final double? discountPrice;
  @override
  final String imageUrl;
  @override
  final String categoryId;
  @override
  final String brand;
  @override
  final double rating;
  @override
  final int reviewCount;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.categoryId,
    required this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          discountPrice: discountPrice,
          imageUrl: imageUrl,
          categoryId: categoryId,
          brand: brand,
          rating: rating,
          reviewCount: reviewCount,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String,
      categoryId: json['categoryId'] as String,
      brand: json['brand'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'brand': brand,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel.fromJson(map);
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      discountPrice: discountPrice,
      imageUrl: imageUrl,
      categoryId: categoryId,
      brand: brand,
      rating: rating,
      reviewCount: reviewCount,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      discountPrice: product.discountPrice,
      imageUrl: product.imageUrl,
      categoryId: product.categoryId,
      brand: product.brand,
      rating: product.rating,
      reviewCount: product.reviewCount,
    );
  }
}
