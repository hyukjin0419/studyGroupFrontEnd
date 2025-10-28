import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/me_provider.dart';
import 'package:study_group_front_end/providers/study_provider.dart';
import 'package:study_group_front_end/snack_bar/show_error_snackbar.dart';

class EditUserNameScreen extends StatefulWidget {
  const EditUserNameScreen({super.key});

  @override
  State<EditUserNameScreen> createState() => _EditUserNameScreenState();
}

class _EditUserNameScreenState extends State<EditUserNameScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<MeProvider>().currentMember;
    _controller.text = currentUser?.userName ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '유저네임 변경',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '새 아이디',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '사용하실 새로운 아이디를 입력하세요.',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF00BFA5),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '유저네임을 입력해주세요';
                        }
                        if (value.length < 2) {
                          return '유저네임은 2자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  '변경하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<MeProvider>().updateUserName(_controller.text);
      await context.read<StudyProvider>().getMyStudies();
      if (mounted) {
        showSuccessSnackBar(context, "아이디가 업데이트 되었습니다!","새로운 아이디으로 다른 사용자에게 표시됩니다");
        Navigator.pop(context);
      }

    } catch (e) {
      String errorMessage;
      try{
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      } catch (_) {
        errorMessage = e.toString();
      }
      if (mounted) {
        showBottomErrorSnackBar(context, errorMessage);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}