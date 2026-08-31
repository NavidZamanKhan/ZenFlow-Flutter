import 'package:equatable/equatable.dart';

import 'insights_state.dart';

abstract class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInsightsEvent extends InsightsEvent {
  const LoadInsightsEvent();
}

class RefreshInsightsEvent extends InsightsEvent {
  const RefreshInsightsEvent();
}

class TimeRangeChangedEvent extends InsightsEvent {
  final InsightsTimeRange timeRange;

  const TimeRangeChangedEvent(this.timeRange);

  @override
  List<Object?> get props => [timeRange];
}
