import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/localization/app_localizations.dart';
import 'package:myecomerceapp/core/localization/locale_keys.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_cubit.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_state.dart';
import 'package:myecomerceapp/presentation/cart/widgets/cart_item_widget.dart';
import 'package:myecomerceapp/presentation/home/pages/payment_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          context.tr(LK.cart),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && !state.isEmpty) {
                return IconButton(
                  onPressed: () => _showClearDialog(context),
                  icon: Icon(Icons.delete_sweep_outlined, color: c.textSecondary),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: TextStyle(color: c.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<CartCubit>().loadCart(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: Text(context.tr(LK.retry), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          if (state is CartLoaded) {
            if (state.isEmpty) return _buildEmptyCart(context);
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, a) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItemWidget(
                        item: item,
                        onQuantityChanged: (qty) =>
                            context.read<CartCubit>().updateItemQuantity(item.product.id, qty),
                        onRemove: () {
                          context.read<CartCubit>().removeItem(item.product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.product.name} ${context.tr(LK.removedFromCart)}'),
                              backgroundColor: AppColors.of(context).surface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildCheckoutBar(context, state),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final c = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, color: c.textHint, size: 80),
          const SizedBox(height: 20),
          Text(context.tr(LK.emptyCart), style: TextStyle(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(context.tr(LK.emptyCartSub), style: TextStyle(color: c.textHint, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartLoaded state) {
    final c = AppColors.of(context);
    final shipping = state.totalPrice >= 50 ? 0.0 : 5.99;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr(LK.subtotal), style: const TextStyle(color: Colors.white70, fontSize: 15)),
              Text('\$${state.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr(LK.shipping), style: const TextStyle(color: Colors.white70, fontSize: 15)),
              Text(
                shipping == 0 ? context.tr(LK.freeShipping) : '\$5.99',
                style: TextStyle(color: shipping == 0 ? AppColors.success : Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: c.divider.withValues(alpha: 0.3)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr(LK.total), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${(state.totalPrice + shipping).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.totalItems >= 1
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentPage()))
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                '${context.tr(LK.checkout)} (${state.totalItems})',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(context.tr(LK.clearCart), style: TextStyle(color: c.textPrimary)),
        content: Text(context.tr(LK.clearCartMsg), style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr(LK.cancel), style: TextStyle(color: c.textHint)),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearAllItems();
              Navigator.pop(ctx);
            },
            child: Text(context.tr(LK.clear), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
