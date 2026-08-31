import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/notifications_engine.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsEngine _engine;

  NotificationsBloc({NotificationsEngine? engine})
      : _engine = engine ?? NotificationsEngine(),
        super(NotificationsState.initial()) {
    on<DeriveNotificationsEvent>(_onDerive);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllAsRead);
  }

  Future<void> _onDerive(
    DeriveNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final list = await _engine.derive(
      tasks: event.tasks,
      events: event.events,
      expenses: event.expenses,
      budget: event.budget,
    );

    final unread = list.where((n) => !n.isRead).length;
    emit(state.copyWith(notifications: list, unreadCount: unread));
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _engine.markAsRead(event.id);

    final updated = state.notifications.map((n) {
      if (n.id == event.id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final unread = updated.where((n) => !n.isRead).length;
    emit(state.copyWith(notifications: updated, unreadCount: unread));
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _engine.markAllAsRead(state.notifications);

    final updated = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();

    emit(state.copyWith(notifications: updated, unreadCount: 0));
  }
}
