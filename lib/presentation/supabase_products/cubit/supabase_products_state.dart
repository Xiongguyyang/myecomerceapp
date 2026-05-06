import 'package:myecomerceapp/data/supabase/models/product_supabase_model.dart';

abstract class SupabaseProductsState {}

class SupabaseProductsInitial extends SupabaseProductsState {}

class SupabaseProductsLoading extends SupabaseProductsState {}

class SupabaseProductsLoaded extends SupabaseProductsState {
  final List<ProductSupabaseModel> products;

  SupabaseProductsLoaded(this.products);
}

class SupabaseProductsError extends SupabaseProductsState {
  final String message;

  SupabaseProductsError(this.message);
}
