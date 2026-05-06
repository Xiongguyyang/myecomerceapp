import 'package:flutter/material.dart';
import 'package:myecomerceapp/data/product/models/product_model.dart';
import 'package:myecomerceapp/domain/product/entities/category_entity.dart';

class ProductLocalDatasource {
  List<CategoryEntity> getCategories() {
    return const [
      CategoryEntity(id: 'all', name: 'All', icon: Icons.apps),
      CategoryEntity(id: 'electronics', name: 'Electronics', icon: Icons.devices),
      CategoryEntity(id: 'clothing', name: 'Clothing', icon: Icons.checkroom),
      CategoryEntity(id: 'shoes', name: 'Shoes', icon: Icons.skateboarding),
      CategoryEntity(id: 'accessories', name: 'Accessories', icon: Icons.watch),
      CategoryEntity(id: 'home', name: 'Home', icon: Icons.home),
      CategoryEntity(id: 'sports', name: 'Sports', icon: Icons.sports_basketball),
      CategoryEntity(id: 'books', name: 'Books', icon: Icons.book),
    ];
  }

  List<ProductModel> getAllProducts() {
    // Data removed - products now loaded from Supabase
    return const [];
  }
}
