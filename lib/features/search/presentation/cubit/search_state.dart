part of 'search_cubit.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded({
    required this.products,
    required this.searchQuery,
    this.selectedCategoryKey,
  });

  final List<SearchProduct> products;
  final String searchQuery;
  final String? selectedCategoryKey;

  @override
  List<Object?> get props => [products, searchQuery, selectedCategoryKey];
}

final class SearchError extends SearchState {
  const SearchError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
