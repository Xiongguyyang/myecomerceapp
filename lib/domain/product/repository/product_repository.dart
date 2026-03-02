import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/domain/product/entities/category_entity.dart';
import 'package:myecomerceapp/domain/product/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<String, List<ProductEntity>>> getAllProducts();
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(String categoryId);
  Future<Either<String, List<ProductEntity>>> searchProducts(String query);
  Future<Either<String, ProductEntity>> getProductById(String id);
  List<CategoryEntity> getCategories();
}
