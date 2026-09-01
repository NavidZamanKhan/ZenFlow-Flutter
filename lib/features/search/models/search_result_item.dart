import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SearchResultType {
  page,
  task,
  expense,
  event,
}

enum SearchFilter {
  all,
  tasks,
  expenses,
  events,
  pages,
}

class SearchResultItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final IconData icon;
  final Color? color;
  final String? badge;
  final Object? rawData;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    this.color,
    this.badge,
    this.rawData,
  });

  @override
  List<Object?> get props => [id, title, subtitle, type, badge];
}
