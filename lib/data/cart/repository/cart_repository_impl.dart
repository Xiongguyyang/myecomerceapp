import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/data/cart/datasource/cart_local_datasource.dart';
import 'package:myecomerceapp/data/product/datasource/product_local_datasource.dart';
import 'package:myecomerceapp/domain/cart/entities/cart_item_entity.dart';
import 'package:myecomerceapp/domain/cart/repository/cart_repository.dart';

class CartRepositoryImpl extends CartRepository {
  final CartLocalDatasource cartDatasource;
  final ProductLocalDatasource productDatasource;

  CartRepositoryImpl({
    required this.cartDatasource,
    required this.productDatasource,
  });

  @override
  Future<Either<String, List<CartItemEntity>>> getCartItems() async {
    try {
      final cartModels = cartDatasource.getCartItems();
      final allProducts = productDatasource.getAllProducts();
      final cartItems = <CartItemEntity>[];

      for (final cartModel in cartModels) {
        try {
          final product = allProducts.firstWhere((p) => p.id == cartModel.productId);
          cartItems.add(CartItemEntity(product: product, quantity: cartModel.quantity));
        } catch (_) {
          // Product not found, skip
        }
      }
      return Right(cartItems);
    } catch (e) {
      return const Left('Failed to load cart');
    }
  }

  @override
  Future<Either<String, void>> addToCart(String productId, int quantity) async {
    try {
      await cartDatasource.addToCart(productId, quantity);
      return const Right(null);
    } catch (e) {
      return const Left('Failed to add to cart');
    }
  }

  @override
  Future<Either<String, void>> removeFromCart(String productId) async {
    try {
      await cartDatasource.removeFromCart(productId);
      return const Right(null);
    } catch (e) {
      return const Left('Failed to remove from cart');
    }
  }

  @override
  Future<Either<String, void>> updateQuantity(String productId, int quantity) async {
    try {
      await cartDatasource.updateQuantity(productId, quantity);
      return const Right(null);
    } catch (e) {
      return const Left('Failed to update quantity');
    }
  }

  @override
  Future<Either<String, void>> clearCart() async {
    try {
      await cartDatasource.clearCart();
      return const Right(null);
    } catch (e) {
      return const Left('Failed to clear cart');
    }
  }

  @override
  Future<Either<String, int>> getCartItemCount() async {
    try {
      final count = cartDatasource.getCartItemCount();
      return Right(count);
    } catch (e) {
      return const Left('Failed to get cart count');
    }
  }
}
