import 'package:flutter/material.dart';

class GreenPillButton extends StatelessWidget {
  const GreenPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 32.0,
    this.horizontalPadding = 14.0,
    this.fontSize = 13.0,
  });

  final String label;
  final VoidCallback onTap;
  final double height;
  final double horizontalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF34D399),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
