import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/presentation/home/pages/learning/data/data.dart';
import 'package:myecomerceapp/presentation/home/pages/learning/cubit and state/state.dart';

class ProductCubit extends Cubit<ProductState>{
  ProductCubit() : super(ProductInitial()){
    loadProducts();
  }

  List<Product> _products = [];

  Future<void> loadProducts() async {
    emit(ProductLoading());
    _products = List.from(initialProducts);
    emit(ProductLoaded(_products));
  }

  void addProduct(Product product) {
    _products.add(product);
    emit(ProductAdded(List.from(_products)));
  }

  void deleteProduct(int id) {
    _products.removeWhere((product) => product.id == id);
    emit(ProductDeleted(List.from(_products)));
  }
}
