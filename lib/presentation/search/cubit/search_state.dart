import 'package:myecomerceapp/domain/product/entities/product_entity.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProductEntity> results;
  final String query;

  SearchLoaded({required this.results, required this.query});

  bool get isEmpty => results.isEmpty;
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
