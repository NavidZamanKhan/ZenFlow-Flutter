import 'package:flutter_bloc/flutter_bloc.dart';

import '../../calendar/models/calendar_item.dart';
import '../../expenses/models/expense_item.dart';
import '../../tasks/models/task_item.dart';
import '../services/search_service.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchService _searchService;
  List<TaskItem> _tasks = [];
  List<ExpenseItem> _expenses = [];
  List<CalendarItem> _events = [];
  String _activeCurrency = 'BDT';

  SearchBloc({SearchService? searchService})
      : _searchService = searchService ?? SearchService(),
        super(const SearchState()) {
    on<SearchQueryChangedEvent>(_onQueryChanged);
    on<SearchFilterChangedEvent>(_onFilterChanged);
    on<ClearSearchEvent>(_onClear);
    on<UpdateSearchSourcesEvent>(_onUpdateSources);
  }

  void _onUpdateSources(
    UpdateSearchSourcesEvent event,
    Emitter<SearchState> emit,
  ) {
    _tasks = event.tasks;
    _expenses = event.expenses;
    _events = event.events;
    _activeCurrency = event.activeCurrency;

    final results = _searchService.search(
      rawQuery: state.query,
      filter: state.filter,
      tasks: _tasks,
      expenses: _expenses,
      events: _events,
      activeCurrency: _activeCurrency,
    );
    emit(state.copyWith(results: results, totalMatches: results.length));
  }

  void _onQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<SearchState> emit,
  ) {
    final results = _searchService.search(
      rawQuery: event.query,
      filter: state.filter,
      tasks: _tasks,
      expenses: _expenses,
      events: _events,
      activeCurrency: _activeCurrency,
    );
    emit(state.copyWith(
      query: event.query,
      results: results,
      totalMatches: results.length,
    ));
  }

  void _onFilterChanged(
    SearchFilterChangedEvent event,
    Emitter<SearchState> emit,
  ) {
    final results = _searchService.search(
      rawQuery: state.query,
      filter: event.filter,
      tasks: _tasks,
      expenses: _expenses,
      events: _events,
      activeCurrency: _activeCurrency,
    );
    emit(state.copyWith(
      filter: event.filter,
      results: results,
      totalMatches: results.length,
    ));
  }

  void _onClear(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    final results = _searchService.search(
      rawQuery: '',
      filter: state.filter,
      tasks: _tasks,
      expenses: _expenses,
      events: _events,
      activeCurrency: _activeCurrency,
    );
    emit(state.copyWith(
      query: '',
      results: results,
      totalMatches: results.length,
    ));
  }
}
