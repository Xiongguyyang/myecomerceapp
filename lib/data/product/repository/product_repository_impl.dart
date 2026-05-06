import 'package:dartz/dartz.dart';
import 'package:myecomerceapp/data/product/datasource/product_local_datasource.dart';
import 'package:myecomerceapp/data/product/models/product_model.dart';
import 'package:myecomerceapp/data/supabase/repositories/product_supabase_repository.dart';
import 'package:myecomerceapp/domain/product/entities/category_entity.dart';
import 'package:myecomerceapp/domain/product/entities/product_entity.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductLocalDatasource datasource;
  final ProductSupabaseRepository supabaseRepository;

  ProductRepositoryImpl(this.datasource, this.supabaseRepository);

  @override
  Future<Either<String, List<ProductEntity>>> getAllProducts() async {
    try {
      print('📦 ProductRepository: Fetching products from Supabase...');
      final supabaseProducts = await supabaseRepository.getAllProducts();
      print('📦 ProductRepository: Received ${supabaseProducts.length} products from Supabase');

      // Convert Supabase models to ProductModel
      final products = supabaseProducts.map((sp) => ProductModel(
        id: sp.id,
        name: sp.name,
        description: sp.description,
        price: sp.price,
        originalPrice: sp.originalPrice,
        imageUrl: sp.imageUrl,
        category: sp.category,
        rating: sp.rating,
        reviewCount: sp.reviewCount,
        inStock: sp.inStock,
        tags: sp.tags,
      )).toList();

      print('📦 ProductRepository: Converted to ${products.length} ProductModels');
      return Right(products);
    } catch (e) {
      print('❌ ProductRepository Error: $e');
      return Left('Failed to load products: $e');
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> getProductsByCategory(String categoryId) async {
    try {
      if (categoryId == 'all') {
        return getAllProducts();
      }

      final supabaseProducts = await supabaseRepository.getProductsByCategory(categoryId);

      final products = supabaseProducts.map((sp) => ProductModel(
        id: sp.id,
        name: sp.name,
        description: sp.description,
        price: sp.price,
        originalPrice: sp.originalPrice,
        imageUrl: sp.imageUrl,
        category: sp.category,
        rating: sp.rating,
        reviewCount: sp.reviewCount,
        inStock: sp.inStock,
        tags: sp.tags,
      )).toList();

      return Right(products);
    } catch (e) {
      return Left('Failed to load products: $e');
    }
  }

  @override
  Future<Either<String, List<ProductEntity>>> searchProducts(String query) async {
    try {
      final supabaseProducts = await supabaseRepository.searchProducts(query);

      final products = supabaseProducts.map((sp) => ProductModel(
        id: sp.id,
        name: sp.name,
        description: sp.description,
        price: sp.price,
        originalPrice: sp.originalPrice,
        imageUrl: sp.imageUrl,
        category: sp.category,
        rating: sp.rating,
        reviewCount: sp.reviewCount,
        inStock: sp.inStock,
        tags: sp.tags,
      )).toList();

      return Right(products);
    } catch (e) {
      return Left('Search failed: $e');
    }
  }

  @override
  Future<Either<String, ProductEntity>> getProductById(String id) async {
    try {
      final supabaseProduct = await supabaseRepository.getProductById(id);

      if (supabaseProduct == null) {
        return const Left('Product not found');
      }

      final product = ProductModel(
        id: supabaseProduct.id,
        name: supabaseProduct.name,
        description: supabaseProduct.description,
        price: supabaseProduct.price,
        originalPrice: supabaseProduct.originalPrice,
        imageUrl: supabaseProduct.imageUrl,
        category: supabaseProduct.category,
        rating: supabaseProduct.rating,
        reviewCount: supabaseProduct.reviewCount,
        inStock: supabaseProduct.inStock,
        tags: supabaseProduct.tags,
      );

      return Right(product);
    } catch (e) {
      return Left('Product not found: $e');
    }
  }

  @override
  List<CategoryEntity> getCategories() {
    return datasource.getCategories();
  }
}
