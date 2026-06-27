import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Single, themed amount input — large bold value with a colored "S/"
/// prefix. Callers are expected to render their own label (e.g. via
/// `FieldLabel`) above; this widget intentionally has NO outer
/// container so it doesn't paint a second rectangle on top of the
/// global `InputDecorationTheme` fill the framework already provides.
class AmountInputField extends StatelessWidget {
  const AmountInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      onChanged: onChanged,
      style: const TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        prefixText: 'S/ ',
        prefixStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        hintText: '0.00',
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
