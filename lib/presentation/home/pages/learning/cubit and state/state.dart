import '../data/data.dart';

abstract class ProductState {} 

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
ProductLoaded(this.products);
}

class ProductAdded extends ProductState {
  final List<Product> products;
ProductAdded(this.products);
}

class ProductDeleted extends ProductState {
  final List<Product> products;
ProductDeleted(this.products);
}

class ProductError extends ProductState {
  final String message;
ProductError(this.message);
}
