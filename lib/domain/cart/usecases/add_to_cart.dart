import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/cart/repository/cart_repository.dart';

class AddToCartParams {
  final String productId;
  final int quantity;

  const AddToCartParams({required this.productId, this.quantity = 1});
}

class AddToCart extends UseCase<void, AddToCartParams> {
  final CartRepository repository;

  AddToCart(this.repository);

  @override
  Future<Either<String, void>> call(AddToCartParams params) {
    return repository.addToCart(params.productId, params.quantity);
  }
}
