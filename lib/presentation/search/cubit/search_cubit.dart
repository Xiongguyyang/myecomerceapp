import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/domain/product/usecases/search_products.dart';
import 'package:myecomerceapp/presentation/search/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProducts _searchProducts;
  Timer? _debounce;

  SearchCubit({required SearchProducts searchProducts})
      : _searchProducts = searchProducts,
        super(SearchInitial());

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await _searchProducts(query.trim());
      result.fold(
        (error) => emit(SearchError(error)),
        (products) => emit(SearchLoaded(results: products, query: query)),
      );
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
