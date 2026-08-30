import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/zenflow_theme.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../widgets/calendar_day_agenda.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_month_grid.dart';
import '../widgets/calendar_view_switcher.dart';
import '../widgets/calendar_week_strip.dart';
import '../widgets/new_event_bottom_sheet.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  void _openNewEventModal(BuildContext context, DateTime selectedDate) {
    NewEventBottomSheet.show(
      context,
      initialDate: selectedDate,
      onEventCreated: (item) {
        context.read<CalendarBloc>().add(AddCalendarItemEvent(item));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: ColoredBox(
        color: zen.canvas,
        child: SafeArea(
          child: BlocBuilder<CalendarBloc, CalendarState>(
            builder: (context, state) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 118),
                children: [
                  // Top Header with Legend & "+ New event"
                  CalendarHeader(
                    onNewEventPressed: () =>
                        _openNewEventModal(context, state.selectedDate),
                  ),
                  const SizedBox(height: 18),

                  // View Switcher [ Month | Week | Schedule ]
                  CalendarViewSwitcher(
                    currentMode: state.viewMode,
                    onModeChanged: (mode) {
                      context.read<CalendarBloc>().add(ChangeViewModeEvent(mode));
                    },
                  ),
                  const SizedBox(height: 18),

                  // Calendar Surface based on View Mode
                  if (state.viewMode == CalendarViewMode.month) ...[
                    CalendarMonthGrid(
                      focusedMonth: state.focusedMonth,
                      selectedDate: state.selectedDate,
                      items: state.items,
                      onDateSelected: (date) {
                        context.read<CalendarBloc>().add(SelectDateEvent(date));
                      },
                      onPreviousMonth: () {
                        context.read<CalendarBloc>().add(const PreviousMonthEvent());
                      },
                      onNextMonth: () {
                        context.read<CalendarBloc>().add(const NextMonthEvent());
                      },
                      onTodayPressed: () {
                        context.read<CalendarBloc>().add(const JumpToTodayEvent());
                      },
                    ),
                    const SizedBox(height: 18),
                    CalendarDayAgenda(
                      selectedDate: state.selectedDate,
                      items: state.itemsForSelectedDate,
                      onAddEventPressed: () =>
                          _openNewEventModal(context, state.selectedDate),
                    ),
                  ] else if (state.viewMode == CalendarViewMode.week) ...[
                    CalendarWeekStrip(
                      selectedDate: state.selectedDate,
                      items: state.items,
                      onDateSelected: (date) {
                        context.read<CalendarBloc>().add(SelectDateEvent(date));
                      },
                    ),
                    const SizedBox(height: 18),
                    CalendarDayAgenda(
                      selectedDate: state.selectedDate,
                      items: state.itemsForSelectedDate,
                      onAddEventPressed: () =>
                          _openNewEventModal(context, state.selectedDate),
                    ),
                  ] else ...[
                    // Schedule / Agenda Only View
                    CalendarDayAgenda(
                      selectedDate: state.selectedDate,
                      items: state.itemsForSelectedDate,
                      onAddEventPressed: () =>
                          _openNewEventModal(context, state.selectedDate),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
