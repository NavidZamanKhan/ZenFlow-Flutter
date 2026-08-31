import 'package:equatable/equatable.dart';

import 'insights_state.dart';

abstract class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInsightsEvent extends InsightsEvent {
  final String activeCurrency;

  const LoadInsightsEvent({this.activeCurrency = 'BDT'});

  @override
  List<Object?> get props => [activeCurrency];
}

class RefreshInsightsEvent extends InsightsEvent {
  final String activeCurrency;

  const RefreshInsightsEvent({this.activeCurrency = 'BDT'});

  @override
  List<Object?> get props => [activeCurrency];
}

class TimeRangeChangedEvent extends InsightsEvent {
  final InsightsTimeRange timeRange;
  final String activeCurrency;

  const TimeRangeChangedEvent(this.timeRange, {this.activeCurrency = 'BDT'});

  @override
  List<Object?> get props => [timeRange, activeCurrency];
}
