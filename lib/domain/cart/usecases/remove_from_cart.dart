import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/cart/repository/cart_repository.dart';

class RemoveFromCart extends UseCase<void, String> {
  final CartRepository repository;

  RemoveFromCart(this.repository);

  @override
  Future<Either<String, void>> call(String productId) {
    return repository.removeFromCart(productId);
  }
}
