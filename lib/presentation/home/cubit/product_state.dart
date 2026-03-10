import 'package:myecomerceapp/domain/product/entities/product_entity.dart';
import 'package:myecomerceapp/domain/product/entities/category_entity.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String selectedCategory;

  ProductLoaded({
    required this.products,
    required this.categories,
    this.selectedCategory = 'all',
  });

  ProductLoaded copyWith({
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? selectedCategory,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
