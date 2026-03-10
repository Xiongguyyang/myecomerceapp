import 'package:shared_preferences/shared_preferences.dart';
import 'package:myecomerceapp/data/cart/models/cart_item_model.dart';

class CartLocalDatasource {
  static const String _cartKey = 'cart_items';
  final SharedPreferences _prefs;

  CartLocalDatasource(this._prefs);

  List<CartItemModel> getCartItems() {
    final jsonString = _prefs.getString(_cartKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    return CartItemModel.decodeList(jsonString);
  }

  Future<void> saveCartItems(List<CartItemModel> items) async {
    await _prefs.setString(_cartKey, CartItemModel.encodeList(items));
  }

  Future<void> addToCart(String productId, int quantity) async {
    final items = getCartItems();
    final existingIndex = items.indexWhere((item) => item.productId == productId);

    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + quantity,
      );
    } else {
      items.add(CartItemModel(productId: productId, quantity: quantity));
    }

    await saveCartItems(items);
  }

  Future<void> removeFromCart(String productId) async {
    final items = getCartItems();
    items.removeWhere((item) => item.productId == productId);
    await saveCartItems(items);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final items = getCartItems();
    final index = items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
      await saveCartItems(items);
    }
  }

  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
  }

  int getCartItemCount() {
    final items = getCartItems();
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
