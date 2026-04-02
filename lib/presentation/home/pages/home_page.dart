import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/localization/app_localizations.dart';
import 'package:myecomerceapp/core/localization/locale_cubit.dart';
import 'package:myecomerceapp/core/localization/locale_keys.dart';
import 'package:myecomerceapp/core/utils/app_responsive.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_cubit.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_state.dart';
import 'package:myecomerceapp/presentation/cart/pages/cart_page.dart';
import 'package:myecomerceapp/presentation/home/cubit/product_cubit.dart';
import 'package:myecomerceapp/presentation/home/cubit/product_state.dart';
import 'package:myecomerceapp/presentation/home/widgets/category_chip.dart';
import 'package:myecomerceapp/presentation/home/widgets/product_card.dart';
import 'package:myecomerceapp/presentation/home/widgets/promotion_banner.dart';
import 'package:myecomerceapp/presentation/product_detail/pages/product_detail_page.dart';
import 'package:myecomerceapp/presentation/profile/pages/profile_page.dart';
import 'package:myecomerceapp/presentation/search/pages/search_page.dart';
import 'package:myecomerceapp/widgets/refresh/app_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
    context.read<CartCubit>().loadCart();
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<ProductCubit>().loadProducts(),
      context.read<CartCubit>().loadCart(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final pad = R.hp(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppRefresh(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context, pad)),
              SliverToBoxAdapter(child: _buildSearchBar(context, pad)),
              const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.only(top: 16), child: PromotionBanner()),
              ),
              SliverToBoxAdapter(child: _sectionTitle(context, LK.categories, pad)),
              SliverToBoxAdapter(child: _buildCategories(context, pad)),
              SliverToBoxAdapter(child: _sectionTitle(context, LK.products, pad)),
              _buildProductGrid(context, pad),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double pad) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName?.trim().isNotEmpty == true)
        ? user!.displayName!
        : (user?.email?.split('@')[0] ?? 'Guest');

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, _) => Padding(
        padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
              child: CircleAvatar(
                radius: R.wp(context, 22),
                backgroundColor: AppColors.surfaceLight,
                child: Icon(Icons.person, color: AppColors.textSecondary, size: R.wp(context, 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr(LK.hello), style: TextStyle(color: AppColors.textHint, fontSize: R.sp(context, 12))),
                  Text(
                    name,
                    style: GoogleFonts.notoSans(fontSize: R.sp(context, 18), fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final count = state is CartLoaded ? state.totalItems : 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
                      icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary, size: 26),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.badge, borderRadius: BorderRadius.circular(10)),
                          child: Text('$count', style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, double pad) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, _) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
        child: Container(
          margin: EdgeInsets.fromLTRB(pad, 16, pad, 0),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: R.wp(context, 14)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textHint, size: 22),
              const SizedBox(width: 10),
              Text(context.tr(LK.searchHint), style: TextStyle(color: AppColors.textHint, fontSize: R.sp(context, 14))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String key, double pad) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, _) => Padding(
        padding: EdgeInsets.fromLTRB(pad, 20, pad, 10),
        child: Text(
          context.tr(key),
          style: TextStyle(color: AppColors.textPrimary, fontSize: R.sp(context, 18), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, double pad) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoaded) return const SizedBox.shrink();
        return SizedBox(
          height: 46,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: pad),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, a) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return CategoryChip(
                category: category,
                isSelected: state.selectedCategory == category.id,
                onTap: () => context.read<ProductCubit>().selectCategory(category.id),
              );
            },
          ),
        );
      },
    );
  }

  SliverPadding _buildProductGrid(BuildContext context, double pad) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      sliver: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.accent))),
            );
          }
          if (state is ProductError) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<ProductCubit>().loadProducts(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text(context.tr(LK.retry), style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: AppColors.textHint, size: 48),
                        const SizedBox(height: 12),
                        Text(context.tr(LK.noProducts), style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: R.gridCols(context),
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = state.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
                    onAddToCart: () {
                      context.read<CartCubit>().addItem(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ${context.tr(LK.addedToCart)}'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  );
                },
                childCount: state.products.length,
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    );
  }
}
