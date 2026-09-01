import 'package:equatable/equatable.dart';

import '../models/search_result_item.dart';

class SearchState extends Equatable {
  final String query;
  final SearchFilter filter;
  final List<SearchResultItem> results;
  final int totalMatches;

  const SearchState({
    this.query = '',
    this.filter = SearchFilter.all,
    this.results = const [],
    this.totalMatches = 0,
  });

  SearchState copyWith({
    String? query,
    SearchFilter? filter,
    List<SearchResultItem>? results,
    int? totalMatches,
  }) {
    return SearchState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      results: results ?? this.results,
      totalMatches: totalMatches ?? this.totalMatches,
    );
  }

  @override
  List<Object?> get props => [query, filter, results, totalMatches];
}
