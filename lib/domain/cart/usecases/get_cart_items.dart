import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/cart/entities/cart_item_entity.dart';
import 'package:myecomerceapp/domain/cart/repository/cart_repository.dart';

class GetCartItems extends UseCase<List<CartItemEntity>, NoParams> {
  final CartRepository repository;

  GetCartItems(this.repository);

  @override
  Future<Either<String, List<CartItemEntity>>> call(NoParams params) {
    return repository.getCartItems();
  }
}
