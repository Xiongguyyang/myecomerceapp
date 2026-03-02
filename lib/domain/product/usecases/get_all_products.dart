import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/product/entities/product_entity.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';

class GetAllProducts extends UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  @override
  Future<Either<String, List<ProductEntity>>> call(NoParams params) {
    return repository.getAllProducts();
  }
}
