import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/orders_cubit.dart';
import '../utils/order_status_ui.dart';
import '../widgets/order_card.dart';
import '../widgets/orders_shimmer.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<OrdersCubit>();
      if (cubit.state is OrdersInitial) {
        cubit.loadOrders();
      }
    });
  }

  void _openOrderDetails(BuildContext context, int orderId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => sl<OrderDetailsCubit>()..loadOrderDetails(orderId),
          child: OrderDetailsScreen(orderId: orderId),
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
          child: BlocConsumer<OrdersCubit, OrdersState>(
            listener: (context, state) {
              if (state is OrdersError) {
                SnackbarUtils.showErrorSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              final selectedStatus = switch (state) {
                OrdersLoaded(:final selectedStatus) => selectedStatus,
                _ => context.read<OrdersCubit>().selectedStatus,
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      'طلباتي',
                      style: AppTextStyles.onboardingTitle(
                        color: Colors.black87,
                      ).copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatusFilters(selectedStatus: selectedStatus),
                  const SizedBox(height: 8),
                  Expanded(
                    child: switch (state) {
                      OrdersInitial() || OrdersLoading() =>
                        const OrdersShimmer(),
                      OrdersError(:final message) => HomeErrorView(
                          message: message,
                          onRetry: () => context.read<OrdersCubit>().retry(),
                        ),
                      OrdersLoaded(:final orders) => orders.isEmpty
                          ? const _OrdersEmptyView()
                          : RefreshIndicator(
                              color: AppColors.primaryBlue,
                              onRefresh: () => context
                                  .read<OrdersCubit>()
                                  .loadOrders(status: selectedStatus),
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                itemCount: orders.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final order = orders[index];
                                  return OrderCard(
                                    order: order,
                                    onTap: () =>
                                        _openOrderDetails(context, order.id),
                                  );
                                },
                              ),
                            ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selectedStatus});

  final String? selectedStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: OrderStatusUi.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = OrderStatusUi.filters[index];
          final isSelected = selectedStatus == filter.value;

          return FilterChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => context
                .read<OrdersCubit>()
                .filterByStatus(filter.value),
            selectedColor: AppColors.primaryBlue.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primaryBlue,
            labelStyle: AppTextStyles.onboardingSubtitle(
              color: isSelected ? AppColors.primaryBlue : Colors.black87,
            ).copyWith(fontSize: 13),
            side: BorderSide(
              color: isSelected ? AppColors.primaryBlue : AppColors.navBarBorder,
            ),
            backgroundColor: AppColors.white,
          );
        },
      ),
    );
  }
}

class _OrdersEmptyView extends StatelessWidget {
  const _OrdersEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: AppColors.subtitleGrey.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات',
              style: AppTextStyles.skipButton(color: Colors.black87)
                  .copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر طلباتك هنا بعد إتمام عملية الشراء',
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingSubtitle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
