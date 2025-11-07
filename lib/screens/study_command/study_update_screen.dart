import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/detail/study_detail_response.dart';
import 'package:study_group_front_end/dto/study/update/study_update_request.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/screens/study_command/widgets/calendar_card.dart';
import 'package:study_group_front_end/screens/study_command/widgets/color_picker_sheet.dart';
import 'package:study_group_front_end/screens/study_command/widgets/input_decoration.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/util/format_korean_date.dart';

class StudyUpdateScreen extends StatefulWidget {
  final StudyUpdateRequest initialData;

  const StudyUpdateScreen({
    super.key,
    required this.initialData,
  });

  @override
  State<StudyUpdateScreen> createState() => _StudyUpdateScreenState();
}

class _StudyUpdateScreenState extends State<StudyUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  final bool _isLoading = false;

  // 날짜/달력 상태
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  bool _calendarOpen = false;

  // 색상 상태
  late Color _selectedColor;

  //완료 상태
  late StudyStatus _status;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialData.dueDate;
    _selectedColor = hexToColor(widget.initialData.personalColor);
    _controller = TextEditingController(text: widget.initialData.name);
    _status = widget.initialData.status;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '팀 수정하기',
          style: Theme.of(context).textTheme.bodyLarge!,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,40,20,0),
                    child: TextFormField(
                      style: Theme.of(context).textTheme.bodyLarge,
                      controller: _controller,
                      textInputAction: TextInputAction.next,
                      decoration: fieldDecoration(
                        context,
                        label: '팀 이름을 수정해주세요.',
                        suffix: InkWell(
                          onTap: _openColorPicker,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '팀 이름은 필수입니다.' : null,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => setState(() => _calendarOpen = !_calendarOpen),
                    child: AbsorbPointer(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                          style: Theme.of(context).textTheme.bodyLarge,
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : formatKoreanDate(_selectedDate!),
                          ),
                          decoration: fieldDecoration(
                            context,
                            label: '팀 프로젝트 마감일을 입력해주세요.',
                            suffix: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //달력
            AnimatedCrossFade(
              crossFadeState: _calendarOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 320),
              firstChild: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CalendarCard(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDate,
                  onPageChanged: (day) => setState(() => _focusedDay = day),
                  onDaySelected: (selectedDate, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDate;
                      _focusedDay = focusedDay;
                      _calendarOpen = false;
                    });
                  }, onClear: () {
                  setState(() {
                    _selectedDate = null;
                    _calendarOpen = false;
                  });
                },
                ),
              ),
              secondChild: const SizedBox(height: 4, width: double.infinity),
            ),

            //TODO 여기 완료하기 버튼 추가
            _buildCompletionSection(),
            const Spacer(),

            // 생성 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _updateStudy,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(
                    '확인',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color:Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openColorPicker() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<Color>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => ColorPickerSheet(
        selected: _selectedColor,
      ),
    );
    if (picked != null) {
      setState(() => _selectedColor = picked);
    }
  }

  Future<void> _updateStudy() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final request = StudyUpdateRequest(
        studyId: widget.initialData.studyId,
        name: _controller.text.trim(),
        personalColor: colorToHex(_selectedColor),
        dueDate: _selectedDate,
        status: _status
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      final provider = context.read<StudyProvider>();
      await provider.updateStudy(request);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('팀이 수정되었습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('수정 실패: $e')));
    }
  }

  Widget _buildCompletionSection() {
    final isDone = _status == StudyStatus.DONE;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: isDone
              ? const Color(0xFFE8F5E9)  // 연한 초록 배경
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleCompletionStatus(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // 체크박스
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isDone,
                      onChanged: (_) => _toggleCompletionStatus(),
                      activeColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 텍스트
                  Expanded(
                    child: Text(
                      isDone ? '팀 프로젝트 완료됨' : '팀 프로젝트 완료하기',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDone
                            ? Colors.green.shade700
                            : Colors.black87,
                      ),
                    ),
                  ),

                  // 상태 아이콘
                  if (isDone)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// 상태 토글 메소드 추가
  void _toggleCompletionStatus() {
    setState(() {
      _status = _status == StudyStatus.DONE
          ? StudyStatus.PROGRESSING
          : StudyStatus.DONE;
    });
  }
}



