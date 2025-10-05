import 'package:flutter/material.dart';

class NameColorField extends StatelessWidget {
  const NameColorField({
    super.key,
    required this.controller,
    required this.selectedColor,
    required this.onTapColor,
  });

  final TextEditingController controller;
  final Color selectedColor;
  final VoidCallback onTapColor;

  InputDecoration _deco(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: '팀 이름을 생성해주세요.',
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withOpacity(0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: InkWell(
          onTap: onTapColor,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: scheme.outline),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: _deco(context),
      validator: (v) =>
      (v == null || v.trim().isEmpty) ? '팀 이름은 필수입니다.' : null,
    );
  }
}
