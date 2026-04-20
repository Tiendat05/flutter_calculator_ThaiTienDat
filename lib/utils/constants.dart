import 'package:flutter/material.dart';

// ─── Light Theme Colors ───────────────────────────────────────────
const Color kLightPrimary = Color(0xFF1E1E1E);
const Color kLightSecondary = Color(0xFF424242);
const Color kLightAccent = Color(0xFFFF6B6B);
const Color kLightBg = Color(0xFFF5F5F5);
const Color kLightDisplay = Color(0xFFFFFFFF);

// ─── Dark Theme Colors ────────────────────────────────────────────
const Color kDarkPrimary = Color(0xFF121212);
const Color kDarkSecondary = Color(0xFF2C2C2C);
const Color kDarkAccent = Color(0xFF4ECDC4);
const Color kDarkBg = Color(0xFF121212);
const Color kDarkDisplay = Color(0xFF1E1E1E);

// ─── Typography ───────────────────────────────────────────────────
const String kFont = 'Roboto';
const double kButtonFontSize = 16;
const double kDisplayFontSize = 32;
const double kHistoryFontSize = 18;

// ─── Layout ───────────────────────────────────────────────────────
const double kButtonSpacing = 12;
const double kButtonRadius = 16;
const double kDisplayRadius = 24;
const double kScreenPadding = 24;

// ─── Animation ────────────────────────────────────────────────────
const Duration kButtonPressDuration = Duration(milliseconds: 200);
const Duration kModeSwitchDuration = Duration(milliseconds: 300);

// ─── Storage Keys ─────────────────────────────────────────────────
const String kKeyHistory = 'calculator_history';
const String kKeyTheme = 'calculator_theme';
const String kKeyMode = 'calculator_mode';
const String kKeyMemory = 'calculator_memory';
const String kKeyAngleMode = 'calculator_angle_mode';
const String kKeyPrecision = 'calculator_precision';
const String kKeyHaptic = 'calculator_haptic';
const String kKeySound = 'calculator_sound';
const String kKeyHistorySize = 'calculator_history_size';
