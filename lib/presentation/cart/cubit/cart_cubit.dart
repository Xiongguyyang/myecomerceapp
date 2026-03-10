import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/cart/usecases/add_to_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/clear_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/get_cart_items.dart';
import 'package:myecomerceapp/domain/cart/usecases/remove_from_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/update_cart_quantity.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartItems _getCartItems;
  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;
  final UpdateCartQuantity _updateCartQuantity;
  final ClearCart _clearCart;

  CartCubit({
    required GetCartItems getCartItems,
    required AddToCart addToCart,
    required RemoveFromCart removeFromCart,
    required UpdateCartQuantity updateCartQuantity,
    required ClearCart clearCart,
  })  : _getCartItems = getCartItems,
        _addToCart = addToCart,
        _removeFromCart = removeFromCart,
        _updateCartQuantity = updateCartQuantity,
        _clearCart = clearCart,
        super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    final result = await _getCartItems(const NoParams());
    result.fold(
      (error) => emit(CartError(error)),
      (items) => emit(CartLoaded(items: items)),
    );
  }

  Future<void> addItem(String productId, {int quantity = 1}) async {
    final result = await _addToCart(AddToCartParams(productId: productId, quantity: quantity));
    result.fold(
      (error) => emit(CartError(error)),
      (_) => loadCart(),
    );
  }

  Future<void> removeItem(String productId) async {
    final result = await _removeFromCart(productId);
    result.fold(
      (error) => emit(CartError(error)),
      (_) => loadCart(),
    );
  }

  Future<void> updateItemQuantity(String productId, int quantity) async {
    final result = await _updateCartQuantity(
      UpdateCartQuantityParams(productId: productId, quantity: quantity),
    );
    result.fold(
      (error) => emit(CartError(error)),
      (_) => loadCart(),
    );
  }

  Future<void> clearAllItems() async {
    final result = await _clearCart(const NoParams());
    result.fold(
      (error) => emit(CartError(error)),
      (_) => emit(CartLoaded(items: [])),
    );
  }
}
