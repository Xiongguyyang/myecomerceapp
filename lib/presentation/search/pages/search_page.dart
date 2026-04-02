import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/localization/app_localizations.dart';
import 'package:myecomerceapp/core/localization/locale_keys.dart';
import 'package:myecomerceapp/core/utils/app_responsive.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_cubit.dart';
import 'package:myecomerceapp/presentation/home/widgets/product_card.dart';
import 'package:myecomerceapp/presentation/product_detail/pages/product_detail_page.dart';
import 'package:myecomerceapp/presentation/search/cubit/search_cubit.dart';
import 'package:myecomerceapp/presentation/search/cubit/search_state.dart';
import 'package:myecomerceapp/presentation/service_locator.dart';
import 'package:myecomerceapp/domain/product/usecases/search_products.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(searchProducts: sl<SearchProducts>()),
      child: const _SearchPageBody(),
    );
  }
}

class _SearchPageBody extends StatefulWidget {
  const _SearchPageBody();

  @override
  State<_SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<_SearchPageBody> {
  final _searchController = TextEditingController();
  final _focusNode        = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = R.gridCols(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (q) {
            context.read<SearchCubit>().search(q);
            setState(() {});
          },
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: context.tr(LK.searchPageHint),
            hintStyle: TextStyle(color: AppColors.textHint),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchCubit>().clearSearch();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close, color: AppColors.textHint),
                  )
                : null,
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial)  return _buildInitial(context);
          if (state is SearchLoading)  return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          if (state is SearchError)    return _buildError(state.message);
          if (state is SearchLoaded) {
            if (state.isEmpty) return _buildNoResults(context, state.query);
            return _buildResults(context, state, cols);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, color: AppColors.textHint.withValues(alpha: 0.5), size: 80),
          const SizedBox(height: 16),
          Text(context.tr(LK.searchForProducts), style: const TextStyle(color: AppColors.textHint, fontSize: 18)),
          const SizedBox(height: 8),
          Text(context.tr(LK.searchTip), style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: AppColors.textHint, size: 60),
          const SizedBox(height: 16),
          Text(
            '${context.tr(LK.noResultsFor)} "$query"',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(context.tr(LK.tryDifferentKeywords), style: const TextStyle(color: AppColors.textHint, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchLoaded state, int cols) {
    final count = state.results.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(R.hp(context), 16, R.hp(context), 12),
          child: Text(
            '$count ${context.tr(LK.resultsFor)} "${state.query}"',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: R.hp(context)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: count,
            itemBuilder: (context, index) {
              final product = state.results[index];
              return ProductCard(
                product: product,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                ),
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
          ),
        ),
      ],
    );
  }
}
