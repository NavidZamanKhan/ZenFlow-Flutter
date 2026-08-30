import 'package:equatable/equatable.dart';

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
