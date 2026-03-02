import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/data/product/datasource/product_local_datasource.dart';
import 'package:myecomerceapp/domain/product/entities/category_entity.dart';
import 'package:myecomerceapp/domain/product/entities/product_entity.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductLocalDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<Either<String, List<ProductEntity>>> getAllProducts() async {
    try {
      final products = datasource.getAllProducts();
      return Right(products);
    } catch (e) {
      return const Left('Failed to load products');
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(String categoryId) async {
    try {
      final products = datasource.getAllProducts();
      if (categoryId == 'all') return Right(products);
      final filtered = products.where((p) => p.category == categoryId).toList();
      return Right(filtered);
    } catch (e) {
      return const Left('Failed to load products');
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> searchProducts(String query) async {
    try {
      final products = datasource.getAllProducts();
      final lowerQuery = query.toLowerCase();
      final filtered = products.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.description.toLowerCase().contains(lowerQuery) ||
            p.category.toLowerCase().contains(lowerQuery) ||
            p.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
      return Right(filtered);
    } catch (e) {
      return const Left('Search failed');
    }
  }

  @override
  Future<Either<String, ProductEntity>> getProductById(String id) async {
    try {
      final products = datasource.getAllProducts();
      final product = products.firstWhere((p) => p.id == id);
      return Right(product);
    } catch (e) {
      return const Left('Product not found');
    }
  }

  @override
  List<CategoryEntity> getCategories() {
    return datasource.getCategories();
  }
}
