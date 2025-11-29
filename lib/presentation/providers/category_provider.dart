import 'package:flutter/material.dart';
import '../../data/datasources/product_firebase_datasource.dart';
import '../../data/models/category_model.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  final ProductFirebaseDataSource productFirebaseDataSource;

  CategoryProvider({required this.productFirebaseDataSource});

  CategoryStatus _status = CategoryStatus.initial;
  List<CategoryModel> _categories = [];
  String? _errorMessage;

  CategoryStatus get status => _status;
  List<CategoryModel> get categories => _categories;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _status = CategoryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await productFirebaseDataSource.getCategories();
      _status = CategoryStatus.loaded;
    } catch (e) {
      _status = CategoryStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCategoryName(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.name ?? categoryId;
  }
}
