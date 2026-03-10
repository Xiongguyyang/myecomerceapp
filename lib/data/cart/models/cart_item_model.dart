import 'dart:convert';

class CartItemModel {
  final String productId;
  final int quantity;

  const CartItemModel({
    required this.productId,
    this.quantity = 1,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      quantity: quantity ?? this.quantity,
    );
  }

  static String encodeList(List<CartItemModel> items) {
    return jsonEncode(items.map((i) => i.toJson()).toList());
  }

  static List<CartItemModel> decodeList(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
