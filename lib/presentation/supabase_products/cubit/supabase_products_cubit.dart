import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/data/supabase/repositories/product_supabase_repository.dart';
import 'package:myecomerceapp/presentation/supabase_products/cubit/supabase_products_state.dart';

class SupabaseProductsCubit extends Cubit<SupabaseProductsState> {
  final ProductSupabaseRepository _repository;

  SupabaseProductsCubit(this._repository) : super(SupabaseProductsInitial());

  Future<void> loadProducts() async {
    emit(SupabaseProductsLoading());
    try {
      final products = await _repository.getAllProducts();
      emit(SupabaseProductsLoaded(products));
    } catch (e) {
      emit(SupabaseProductsError(e.toString()));
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    emit(SupabaseProductsLoading());
    try {
      final products = await _repository.getProductsByCategory(category);
      emit(SupabaseProductsLoaded(products));
    } catch (e) {
      emit(SupabaseProductsError(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    emit(SupabaseProductsLoading());
    try {
      final products = await _repository.searchProducts(query);
      emit(SupabaseProductsLoaded(products));
    } catch (e) {
      emit(SupabaseProductsError(e.toString()));
    }
  }

  Future<void> loadFilteredProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) async {
    emit(SupabaseProductsLoading());
    try {
      final products = await _repository.getFilteredProducts(
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStock: inStock,
      );
      emit(SupabaseProductsLoaded(products));
    } catch (e) {
      emit(SupabaseProductsError(e.toString()));
    }
  }
}
