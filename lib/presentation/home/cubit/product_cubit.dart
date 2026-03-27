import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/core/usecase/usecase.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';
import 'package:myecomerceapp/domain/product/usecases/get_all_products.dart';
import 'package:myecomerceapp/domain/product/usecases/get_products_by_category.dart';
import 'package:myecomerceapp/presentation/home/cubit/product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetAllProducts _getAllProducts;
  final GetProductsByCategory _getProductsByCategory;
  final ProductRepository _productRepository;

  ProductCubit({
    required GetAllProducts getAllProducts,
    required GetProductsByCategory getProductsByCategory,
    required ProductRepository productRepository,
  })  : _getAllProducts = getAllProducts,
        _getProductsByCategory = getProductsByCategory,
        _productRepository = productRepository,
        super(ProductInitial());

  Future<void> loadProducts() async {
    emit(ProductLoading());
    final result = await _getAllProducts(const NoParams());
    result.fold(
      (error) => emit(ProductError(error)),
      (products) => emit(ProductLoaded(
        products: products,
        categories: _productRepository.getCategories(),
      )),
    );
  }

  Future<void> selectCategory(String categoryId) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    emit(ProductLoading());
    final result = await _getProductsByCategory(categoryId);
    result.fold(
      (error) => emit(ProductError(error)),
      (products) => emit(ProductLoaded(
        products: products,
        categories: currentState.categories,
        selectedCategory: categoryId,
      )),
    );
  }
}
