import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/cart/repository/cart_repository.dart';

class ClearCart extends UseCase<void, NoParams> {
  final CartRepository repository;

  ClearCart(this.repository);

  @override
  Future<Either<String, void>> call(NoParams params) {
    return repository.clearCart();
  }
}
