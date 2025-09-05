import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onClear,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final void Function(DateTime focusedDay) onPageChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: hexToColor("0xFFF7F8FA"),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            availableGestures: AvailableGestures.horizontalSwipe,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM('ko_KR').format(date),
              leftChevronIcon: const Icon(Icons.chevron_left),
              rightChevronIcon: const Icon(Icons.chevron_right),
              titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: hexToColor("0xFFB8B8B8")),
                ),
              ),
            ),
            daysOfWeekHeight: 35,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: Theme.of(context).textTheme.titleSmall!,
              weekendStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.redAccent),
            ),
            calendarStyle: CalendarStyle(
              tablePadding: EdgeInsets.only(top: 20),
              isTodayHighlighted: true,
              outsideDaysVisible: true,
              defaultDecoration: const BoxDecoration(shape: BoxShape.rectangle),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.primary),
              ),
              todayTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: scheme.onSurfaceVariant.withOpacity(0.5)),
              selectedDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              outsideTextStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: scheme.onSurfaceVariant.withOpacity(0.5)),
              weekendTextStyle: Theme.of(context).textTheme.titleSmall!,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 600,
            height: 45,
            child: FilledButton(
              onPressed: onClear,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                  '선택하지 않음',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.redAccent)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
