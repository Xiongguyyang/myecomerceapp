import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/localization/app_localizations.dart';
import 'package:myecomerceapp/core/localization/locale_keys.dart';
import 'package:myecomerceapp/core/utils/app_responsive.dart';
import 'package:myecomerceapp/domain/product/entities/product_entity.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_cubit.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: R.wp(context, 300).clamp(220.0, 400.0),
              pinned: true,
              backgroundColor: AppColors.primaryDark,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: AppColors.surfaceLight,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, e, s) => Container(
                    color: AppColors.surfaceLight,
                    child: const Center(child: Icon(Icons.image_not_supported, color: AppColors.textHint, size: 60)),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(R.hp(context) + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(product.name, style: TextStyle(color: AppColors.textPrimary, fontSize: R.sp(context, 22), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < product.rating.floor() ? Icons.star : (i < product.rating ? Icons.star_half : Icons.star_border),
                          color: AppColors.star, size: 22,
                        )),
                        const SizedBox(width: 8),
                        Text('${product.rating}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text('(${product.reviewCount} ${context.tr(LK.reviews)})', style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: AppColors.accent, fontSize: R.sp(context, 30), fontWeight: FontWeight.bold)),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '\$${product.originalPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.textHint, fontSize: 18, decoration: TextDecoration.lineThrough),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 16),
                    Text(context.tr(LK.description), style: TextStyle(color: AppColors.textPrimary, fontSize: R.sp(context, 17), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(product.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6)),
                    const SizedBox(height: 20),
                    if (product.tags.isNotEmpty) ...[
                      Text(context.tr(LK.tags), style: TextStyle(color: AppColors.textPrimary, fontSize: R.sp(context, 17), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: product.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text('#$tag', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Stock status
                    Row(
                      children: [
                        Icon(product.inStock ? Icons.check_circle : Icons.cancel,
                            color: product.inStock ? AppColors.success : AppColors.error, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          product.inStock ? context.tr(LK.inStock) : context.tr(LK.outOfStock),
                          style: TextStyle(color: product.inStock ? AppColors.success : AppColors.error, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(R.hp(context), 16, R.hp(context), MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () { if (_quantity > 1) setState(() => _quantity--); },
                    icon: const Icon(Icons.remove, color: AppColors.textPrimary, size: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('$_quantity', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: product.inStock
                    ? () {
                        context.read<CartCubit>().addItem(product.id, quantity: _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$_quantity x ${product.name} ${context.tr(LK.addedToCart)}'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor: AppColors.textHint,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '${context.tr(LK.addToCart)} — \$${(product.price * _quantity).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
