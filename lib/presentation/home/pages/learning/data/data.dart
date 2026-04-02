class Product {
  final int id;
  final String name;
  int? price;


  Product({required this.id, required this.name, this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}

List<Product> products = [
  Product(id: 1, name: "jk", price: 9000),
  Product(id: 2, name: "jk", price: 200),
];