import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/dto/study/create/study_create_request.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/screens/study_command/widgets/calendar_card.dart';
import 'package:study_group_front_end/screens/study_command/widgets/color_picker_sheet.dart';
import 'package:study_group_front_end/screens/study_command/widgets/input_decoration.dart';
import 'package:study_group_front_end/util/color_converters.dart';
import 'package:study_group_front_end/util/formatKoreanDate.dart';

class CreateStudyScreen extends StatefulWidget {
  const CreateStudyScreen({super.key});
  @override
  State<CreateStudyScreen> createState() => _CreateStudyScreenState();
}

class _CreateStudyScreenState extends State<CreateStudyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isLoading = false;

  // 날짜/달력 상태
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  bool _calendarOpen = false;

  // 색상 상태
  Color _selectedColor = const Color(0xFFF28B82);


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
          '팀 생성하기',
            style: Theme.of(context).textTheme.displayMedium,
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
                        label: '팀 이름을 생성해주세요.',
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

            const Spacer(),

            // 생성 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createStudy,
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
                        '생성',
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

  Future<void> _createStudy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final request = StudyCreateRequest(
        name: _controller.text.trim(),
        color: colorToHex(_selectedColor),
        dueDate: _selectedDate
      );

      final provider = context.read<StudyProvider>();
      await provider.createStudy(request);

      //test용으로 넣어보자 -> ux 어떻게 느껴지는지
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('팀이 생성되었습니다.')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('생성 실패: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

}

