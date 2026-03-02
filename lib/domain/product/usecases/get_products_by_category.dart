import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/product/entities/product_entity.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';

class GetProductsByCategory extends UseCase<List<ProductEntity>, String> {
  final ProductRepository repository;

  GetProductsByCategory(this.repository);

  @override
  Future<Either<String, List<ProductEntity>>> call(String categoryId) {
    return repository.getProductsByCategory(categoryId);
  }
}
