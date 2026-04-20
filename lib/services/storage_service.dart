import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../utils/constants.dart';

class StorageService {
  // ─── History ──────────────────────────────────────────────────
  static Future<void> saveHistory(
    List<CalculationHistory> history, {
    int limit = 50,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = history.length > limit
        ? history.sublist(history.length - limit)
        : history;
    final strings = trimmed.map((e) => e.toStorageString()).toList();
    await prefs.setStringList(kKeyHistory, strings);
  }

  static Future<List<CalculationHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final strings = prefs.getStringList(kKeyHistory) ?? [];
    return strings
        .map(CalculationHistory.fromStorageString)
        .whereType<CalculationHistory>()
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kKeyHistory);
  }

  // ─── Theme ────────────────────────────────────────────────────
  static Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kKeyTheme, theme);
  }

  static Future<String> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kKeyTheme) ?? 'dark';
  }

  // ─── Mode ─────────────────────────────────────────────────────
  static Future<void> saveMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kKeyMode, mode);
  }

  static Future<String> loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kKeyMode) ?? 'basic';
  }

  // ─── Memory ───────────────────────────────────────────────────
  static Future<void> saveMemory(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(kKeyMemory, value);
  }

  static Future<double> loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(kKeyMemory) ?? 0.0;
  }

  // ─── Angle mode ───────────────────────────────────────────────
  static Future<void> saveAngleMode(bool isRad) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kKeyAngleMode, isRad);
  }

  static Future<bool> loadAngleMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kKeyAngleMode) ?? false;
  }

  // ─── Settings ─────────────────────────────────────────────────
  static Future<void> saveSettings({
    required int precision,
    required bool haptic,
    required bool sound,
    required int historySize,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kKeyPrecision, precision);
    await prefs.setBool(kKeyHaptic, haptic);
    await prefs.setBool(kKeySound, sound);
    await prefs.setInt(kKeyHistorySize, historySize);
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'precision': prefs.getInt(kKeyPrecision) ?? 6,
      'haptic': prefs.getBool(kKeyHaptic) ?? true,
      'sound': prefs.getBool(kKeySound) ?? false,
      'historySize': prefs.getInt(kKeyHistorySize) ?? 50,
    };
  }
}
