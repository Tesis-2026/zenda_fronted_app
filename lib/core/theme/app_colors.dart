import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF34D399);
  static const primaryDark = Color(0xFF10B981);
  static const primaryLight = Color(0xFFECFDF5);

  // Text — light mode
  static const textDark = Color(0xFF1F2937);
  static const textMid = Color(0xFF374151);
  static const textMuted = Color(0xFF6B7280);
  static const textSubtle = Color(0xFF9CA3AF);

  // Surfaces — light mode
  static const pageBackground = Color(0xFFF9FAFB);
  static const cardBackground = Colors.white;
  static const fillLight = Color(0xFFF3F4F6);
  static const border = Color(0xFFE5E7EB);

  // Surfaces — dark mode
  static const darkPageBackground = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
  static const darkCardElevated = Color(0xFF263244);
  static const darkBorder = Color(0xFF334155);
  static const darkFill = Color(0xFF1E293B);

  // Text — dark mode
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextMuted = Color(0xFF94A3B8);
  static const darkTextSubtle = Color(0xFF64748B);

  // Semantic
  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const info = Color(0xFF818CF8);
  static const infoLight = Color(0xFFEDE9FE);

  // Income / expense
  static const income = Color(0xFF059669);
  static const expense = Color(0xFFEF4444);
}
