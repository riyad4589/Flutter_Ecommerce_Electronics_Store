import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel.fromJson(map);

  Category toEntity() => Category(id: id, name: name, imageUrl: imageUrl);
}
