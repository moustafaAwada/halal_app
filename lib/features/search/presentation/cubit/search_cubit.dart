import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/search_category.dart';
import '../../domain/entities/search_product.dart';
import '../../domain/usecases/search_products.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required SearchProductsUseCase searchProductsUseCase})
      : _searchProductsUseCase = searchProductsUseCase,
        super(const SearchInitial());

  final SearchProductsUseCase _searchProductsUseCase;

  static const categories = <SearchCategory>[
    SearchCategory(key: 'fast_food', label: 'وجبات رئيسية'),
    SearchCategory(key: 'pizza', label: 'بيتزا'),
    SearchCategory(key: 'burger', label: 'برجر'),
    SearchCategory(key: 'grill', label: 'مشويات'),
    SearchCategory(key: 'seafood', label: 'مأكولات بحرية'),
    SearchCategory(key: 'desserts', label: 'حلويات'),
    SearchCategory(key: 'coffee', label: 'مشروبات'),
    SearchCategory(key: 'appetizers', label: 'مقبلات'),
    SearchCategory(key: 'salads', label: 'سلطات'),
  ];

  Timer? _debounceTimer;
  String _searchQuery = '';
  String? _selectedCategoryKey;

  String get searchQuery => _searchQuery;
  String? get selectedCategoryKey => _selectedCategoryKey;

  bool get isSearchActive =>
      _searchQuery.trim().isNotEmpty || _selectedCategoryKey != null;

  Future<void> loadProducts() {
    if (!isSearchActive) {
      emit(const SearchInitial());
      return Future.value();
    }
    return _fetchProducts();
  }

  void onSearchChanged(String value) {
    _searchQuery = value;
    _debounceTimer?.cancel();

    if (!isSearchActive) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    _debounceTimer = Timer(const Duration(milliseconds: 400), _fetchProducts);
  }

  void onCategorySelected(String categoryKey) {
    _debounceTimer?.cancel();
    _selectedCategoryKey =
        _selectedCategoryKey == categoryKey ? null : categoryKey;

    if (!isSearchActive) {
      emit(const SearchInitial());
      return;
    }

    _fetchProducts();
  }

  Future<void> retry() => _fetchProducts();

  Future<void> _fetchProducts() async {
    if (!isSearchActive) {
      emit(const SearchInitial());
      return;
    }

    final querySnapshot = _searchQuery;
    final categorySnapshot = _selectedCategoryKey;

    emit(const SearchLoading());

    final result = await _searchProductsUseCase(
      SearchProductsParams(
        search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        categoryName: _selectedCategoryKey,
      ),
    );

    if (querySnapshot != _searchQuery ||
        categorySnapshot != _selectedCategoryKey ||
        !isSearchActive) {
      return;
    }

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (products) => emit(
        SearchLoaded(
          products: products,
          searchQuery: _searchQuery,
          selectedCategoryKey: _selectedCategoryKey,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
