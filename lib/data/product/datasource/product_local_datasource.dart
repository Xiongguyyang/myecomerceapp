import 'package:flutter/material.dart';
import 'package:myecomerceapp/data/product/models/product_model.dart';
import 'package:myecomerceapp/domain/product/entities/category_entity.dart';

class ProductLocalDatasource {
  List<CategoryEntity> getCategories() {
    return const [
      CategoryEntity(id: 'all', name: 'All', icon: Icons.apps),
      CategoryEntity(
        id: 'Electronics',
        name: 'Electronics',
        icon: Icons.devices,
      ),
      CategoryEntity(id: 'Fashion', name: 'Fashion', icon: Icons.checkroom),
      CategoryEntity(id: 'Home', name: 'Home', icon: Icons.home),
      CategoryEntity(
        id: 'Sports',
        name: 'Sports',
        icon: Icons.sports_basketball,
      ),
    ];
  }

  List<ProductModel> getAllProducts() {
    // Data removed - products now loaded from Supabase
    return const [];
  }
}
