import 'package:flutter/material.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/util/date_calculator.dart';
import 'package:study_group_front_end/util/format_korean_date.dart';
import 'package:table_calendar/table_calendar.dart';

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
  final CalendarFormat _calendarFormat = CalendarFormat.week;
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

  @override
  void didUpdateWidget(WeeklyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // initialSelectedDay가 변경되면 _selectedDay와 _focusedDay 업데이트
    if (widget.initialSelectedDay != oldWidget.initialSelectedDay) {
      setState(() {
        _selectedDay = widget.initialSelectedDay ?? DateTime.now();
        _focusedDay = getMondayOfWeek(widget.initialSelectedDay ?? DateTime.now());
      });
    }
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20,0,8,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                formatKoreanMonth(_focusedDay),
                style: Theme.of(context).textTheme.bodyMedium
              ),
              const SizedBox(width: 4),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,10,0),
            child: Row(
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
                    });
                  },
                ),
                SizedBox(
                  width: 25,
                  height: 25,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(5,5),
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
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
                    child: Text(
                      "주",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )
                    ),
                  ),
                ),
              ],
            ),
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
      headerVisible: false,
      daysOfWeekHeight: 18,
      startingDayOfWeek: StartingDayOfWeek.sunday,

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

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.titleSmall!,
        weekendStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.redAccent),
      ),

      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.fromLTRB(15, 12.5, 15, 12.5),
        todayDecoration: BoxDecoration(
          border: Border.all(color: _color),
          borderRadius: BorderRadius.circular(3)
        ),
        todayTextStyle: const TextStyle(
          color: Colors.black
        ),
        selectedDecoration:
          BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(3)
        ),
        selectedTextStyle: const TextStyle(
            color: Colors.white
        ),
        defaultTextStyle: const TextStyle(color: Colors.black),

        defaultDecoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        weekendDecoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        outsideDecoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        disabledDecoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
        holidayDecoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}
