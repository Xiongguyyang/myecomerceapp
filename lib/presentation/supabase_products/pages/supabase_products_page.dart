import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/presentation/supabase_products/cubit/supabase_products_cubit.dart';
import 'package:myecomerceapp/presentation/supabase_products/cubit/supabase_products_state.dart';

class SupabaseProductsPage extends StatelessWidget {
  const SupabaseProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products from Supabase'),
        backgroundColor: c.background,
        elevation: 0,
      ),
      backgroundColor: c.background,
      body: BlocBuilder<SupabaseProductsCubit, SupabaseProductsState>(
        builder: (context, state) {
          if (state is SupabaseProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SupabaseProductsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SupabaseProductsCubit>().loadProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SupabaseProductsLoaded) {
            if (state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: c.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(color: c.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<SupabaseProductsCubit>().loadProducts(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Products: ${state.products.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
                          columns: const [
                            DataColumn(label: Text('Image')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Original Price')),
                            DataColumn(label: Text('Discount')),
                            DataColumn(label: Text('Rating')),
                            DataColumn(label: Text('Reviews')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Tags')),
                          ],
                          rows: state.products.map((product) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: c.surface,
                                          child: Icon(Icons.image_not_supported, color: c.textSecondary),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      product.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(Text(product.category)),
                                DataCell(
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    product.originalPrice != null
                                        ? '\$${product.originalPrice!.toStringAsFixed(2)}'
                                        : '-',
                                    style: TextStyle(
                                      decoration: product.hasDiscount
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  product.hasDiscount
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '-${product.discountPercentage.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : const Text('-'),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(product.rating.toStringAsFixed(1)),
                                    ],
                                  ),
                                ),
                                DataCell(Text(product.reviewCount.toString())),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: product.inStock
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product.inStock ? 'In Stock' : 'Out of Stock',
                                      style: TextStyle(
                                        color: product.inStock ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: product.tags.take(3).map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: c.surface,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: c.textSecondary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SupabaseProductsCubit>().loadProducts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
