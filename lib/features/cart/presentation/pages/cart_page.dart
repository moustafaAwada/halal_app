import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../domain/entities/order.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_shimmer.dart';
import '../widgets/cart_summary_bar.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CartView();
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  Future<void> _showClearCartDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تفريغ السلة'),
          content: const Text('هل تريد إزالة جميع المنتجات من السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('تفريغ'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<CartCubit>().clearCart();
    }
  }

  void _openCheckout(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<CartCubit>(),
          child: CheckoutPage(order: orders.first),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        body: SafeArea(
          child: BlocConsumer<CartCubit, CartState>(
            listener: (context, state) {
              if (state is CartOrderCreated) {
                _openCheckout(context, state.orders);
                context.read<CartCubit>().loadCart();
              }
            },
            buildWhen: (previous, current) =>
                current is! CartOrderCreated &&
                current is! CartOrderConfirmed,
            builder: (context, state) {
              return switch (state) {
                CartInitial() || CartLoading() => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CartHeader(
                        itemCount: 0,
                        showClear: false,
                        onClear: () {},
                      ),
                      const Expanded(child: CartShimmer()),
                    ],
                  ),
                CartError(:final message) => Column(
                    children: [
                      _CartHeader(
                        itemCount: 0,
                        showClear: false,
                        onClear: () {},
                      ),
                      Expanded(
                        child: HomeErrorView(
                          message: message,
                          onRetry: () => context.read<CartCubit>().retry(),
                        ),
                      ),
                    ],
                  ),
                CartLoaded(:final items, :final isBusy) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CartHeader(
                        itemCount: items.length,
                        showClear: items.isNotEmpty,
                        onClear: () => _showClearCartDialog(context),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? const _CartEmptyView()
                            : RefreshIndicator(
                                color: AppColors.primaryBlue,
                                onRefresh: () =>
                                    context.read<CartCubit>().loadCart(),
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return CartItemTile(
                                      item: item,
                                      isBusy: isBusy,
                                      onIncrease: () => context
                                          .read<CartCubit>()
                                          .updateQuantity(
                                            item.id,
                                            item.quantity + 1,
                                          ),
                                      onDecrease: () => context
                                          .read<CartCubit>()
                                          .updateQuantity(
                                            item.id,
                                            item.quantity - 1,
                                          ),
                                      onRemove: () => context
                                          .read<CartCubit>()
                                          .removeItem(item.id),
                                    );
                                  },
                                ),
                              ),
                      ),
                      if (items.isNotEmpty)
                        CartSummaryBar(
                          total: state.total,
                          isBusy: isBusy,
                          onCheckout: () =>
                              context.read<CartCubit>().createOrder(),
                        ),
                    ],
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({
    required this.itemCount,
    required this.showClear,
    required this.onClear,
  });

  final int itemCount;
  final bool showClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السلة',
                  style: AppTextStyles.skipButton(color: Colors.black87)
                      .copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount ${itemCount == 1 ? 'منتج' : 'منتجات'}',
                  style: AppTextStyles.onboardingSubtitle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (showClear)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('تفريغ'),
            ),
        ],
      ),
    );
  }
}

class _CartEmptyView extends StatelessWidget {
  const _CartEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: AppColors.primaryBlue.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'سلتك فارغة',
              style: AppTextStyles.skipButton(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف منتجات من الصفحة الرئيسية أو المفضلة',
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingSubtitle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
