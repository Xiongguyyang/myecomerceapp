import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/presentation/home/cubit/product_state.dart';

class Product extends Cubit<ProductState>{
  Product() : super(ProductInitial()){
    loadProducts();
  }
  
  void loadProducts() async {
    emit(ProductLoading());
    await Future.delayed(const Duration(seconds: 1));
  }
}