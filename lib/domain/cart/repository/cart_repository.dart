import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/domain/cart/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<String, List<CartItemEntity>>> getCartItems();
  Future<Either<String, void>> addToCart(String productId, int quantity);
  Future<Either<String, void>> removeFromCart(String productId);
  Future<Either<String, void>> updateQuantity(String productId, int quantity);
  Future<Either<String, void>> clearCart();
  Future<Either<String, int>> getCartItemCount();
}
