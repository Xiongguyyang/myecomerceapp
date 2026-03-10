import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/product/entities/product_entity.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';

class SearchProducts extends UseCase<List<ProductEntity>, String> {
  final ProductRepository repository;

  SearchProducts(this.repository);

  @override
  Future<Either<String, List<ProductEntity>>> call(String query) {
    return repository.searchProducts(query);
  }
}
