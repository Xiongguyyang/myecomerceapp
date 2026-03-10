import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/cart/repository/cart_repository.dart';

class UpdateCartQuantityParams {
  final String productId;
  final int quantity;

  const UpdateCartQuantityParams({required this.productId, required this.quantity});
}

class UpdateCartQuantity extends UseCase<void, UpdateCartQuantityParams> {
  final CartRepository repository;

  UpdateCartQuantity(this.repository);

  @override
  Future<Either<String, void>> call(UpdateCartQuantityParams params) {
    return repository.updateQuantity(params.productId, params.quantity);
  }
}
