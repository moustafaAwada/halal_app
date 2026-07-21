import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../domain/entities/search_product.dart';
import '../cubit/search_cubit.dart';
import '../widgets/search_category_chip.dart';
import '../widgets/search_product_card.dart';
import '../widgets/search_shimmer.dart';
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>()..loadProducts(),
      child: _SearchView(searchController: _searchController),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              final cubit = context.read<SearchCubit>();

              return Column(
                children: [
                  _SearchField(controller: searchController),
                  _CategoryFilters(
                    selectedCategoryKey: cubit.selectedCategoryKey,
                  ),
                  Expanded(
                    child: switch (state) {
                      SearchInitial() || SearchLoading() => const SearchShimmer(),
                      SearchError(:final message) => HomeErrorView(
                          message: message,
                          onRetry: cubit.retry,
                        ),
                      SearchLoaded(:final products) => products.isEmpty
                          ? const SearchEmptyView()
                          : _ProductList(products: products),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.searchBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.subtitleGrey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                style: AppTextStyles.onboardingSubtitle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'ابحث عن وجبتك المفضلة...',
                  hintStyle: AppTextStyles.onboardingSubtitle(),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: context.read<SearchCubit>().onSearchChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selectedCategoryKey});

  final String? selectedCategoryKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الأقسام',
              style: AppTextStyles.onboardingTitle(color: Colors.black87),
            ),
          ),
        ),
        SizedBox(          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: SearchCubit.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = SearchCubit.categories[index];
              return SearchCategoryChip(
                label: category.label,
                isSelected: selectedCategoryKey == category.key,
                onTap: () =>
                    context.read<SearchCubit>().onCategorySelected(category.key),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products});

  final List<SearchProduct> products;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return SearchProductCard(product: products[index]);
      },
    );
  }
}
