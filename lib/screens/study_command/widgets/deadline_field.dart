import 'package:flutter/material.dart';

class DeadlineField extends StatelessWidget {
  const DeadlineField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  final String label;
  final String valueText;
  final VoidCallback onTap;

  InputDecoration _deco(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withOpacity(0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: const Padding(
        padding: EdgeInsets.only(right: 6),
        child: Icon(Icons.arrow_drop_down),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TextFormField를 클릭해도 상위 onTap만 동작하도록 IgnorePointer 사용
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: valueText),
          decoration: _deco(context),
          readOnly: true,
        ),
      ),
    );
  }
}
