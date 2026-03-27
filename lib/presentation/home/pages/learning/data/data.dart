class Product {
  final int id;
  final String name;
int price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}

List<Product> initialProducts = [
  Product(id: 1, name: "Josh", price: 9000),
  Product(id: 2, name: "Mr Jk", price: 200),
  Product(id: 3, name: "Timmber", price: 300),
];
