import 'package:myecomerceapp/core/config/supabase_config.dart';
import 'package:myecomerceapp/data/supabase/models/product_supabase_model.dart';

class ProductSupabaseRepository {
  final _client = SupabaseConfig.client;
  static const String tableName = 'products';

  // Fetch all products
  Future<List<ProductSupabaseModel>> getAllProducts() async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ProductSupabaseModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Fetch products by category
  Future<List<ProductSupabaseModel>> getProductsByCategory(String category) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ProductSupabaseModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  // Search products by name
  Future<List<ProductSupabaseModel>> searchProducts(String query) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ProductSupabaseModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get product by ID
  Future<ProductSupabaseModel?> getProductById(String id) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .single();

      return ProductSupabaseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Insert a new product
  Future<void> insertProduct(ProductSupabaseModel product) async {
    try {
      await _client.from(tableName).insert(product.toJson());
    } catch (e) {
      throw Exception('Failed to insert product: $e');
    }
  }

  // Update a product
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _client.from(tableName).update(data).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      await _client.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Real-time subscription to products
  Stream<List<ProductSupabaseModel>> subscribeToProducts() {
    return _client
        .from(tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => ProductSupabaseModel.fromJson(item)).toList());
  }

  // Get products with filters
  Future<List<ProductSupabaseModel>> getFilteredProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) async {
    try {
      var query = _client.from(tableName).select();

      if (category != null) {
        query = query.eq('category', category);
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      if (inStock != null) {
        query = query.eq('in_stock', inStock);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((item) => ProductSupabaseModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch filtered products: $e');
    }
  }
}
