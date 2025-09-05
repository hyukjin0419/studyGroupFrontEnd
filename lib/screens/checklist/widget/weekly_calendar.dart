import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/util/date_calculator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class WeeklyCalendar extends StatefulWidget{
  //초기  날짜 (기본값은 오늘)
  final DateTime? initialSelectedDay;
  //날짜가 되었을 때 외부로 콜백 전달 -> cia를 target_date로 필터링
  final Function(DateTime selectedDay)? onDaySelected;
  final StudyDetailResponse study;

  const WeeklyCalendar({
    super.key,
    this.initialSelectedDay,
    this.onDaySelected,
    required this.study
  });

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late final Color _color;

  @override
  void initState(){
    super.initState();
    _focusedDay = getMondayOfWeek(widget.initialSelectedDay ?? DateTime.now());
    _selectedDay = widget.initialSelectedDay ?? DateTime.now();
    _color = hexToColor(widget.study.personalColor);
    // log("Focused Day : $_focusedDay");
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        _buildCustomHeader(),
        const SizedBox(height: 8),
        _buildCalendar(),
      ],
    );
  }

  Widget _buildCustomHeader() {
    final koreanMonth = DateFormat("yyyy년 M월").format(_focusedDay);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20,0,8,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(koreanMonth, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down), //이거 뭔지 디자이너에게 질문!
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                padding: EdgeInsets.all(5),
                visualDensity: const VisualDensity(horizontal: -4),
                onPressed: () {
                  setState(() {
                    _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                    // log("Focused Day : $_focusedDay");
                  });
                },
              ),
              // SizedBox(width: 0),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                padding: EdgeInsets.all(5),
                visualDensity: const VisualDensity(horizontal: -4),
                onPressed: () {
                  setState(() {
                    _focusedDay = _focusedDay.add(const Duration(days: 7));
                    // log("Focused Day : $_focusedDay");
                  });
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(5,5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: 달력 포맷 전환 (월간 보기)
                },
                child: const Text("주"),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildCalendar() {
    return TableCalendar(
      rowHeight: 50,
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      calendarFormat: _calendarFormat,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });

        widget.onDaySelected?.call(selectedDay);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      headerVisible: false,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        todayDecoration: BoxDecoration(
          border: Border.all(color: _color),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: Colors.black
        ),
        selectedDecoration:
          BoxDecoration(
            shape: BoxShape.circle,
            color: _color,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white),
        defaultTextStyle: const TextStyle(color: Colors.black),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
        weekendStyle: TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
