import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

enum AppTheme { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.dark;

  AppTheme get theme => _theme;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final saved = await StorageService.loadTheme();
    switch (saved) {
      case 'light':
        _theme = AppTheme.light;
        break;
      case 'system':
        _theme = AppTheme.system;
        break;
      default:
        _theme = AppTheme.dark;
    }
    notifyListeners();
  }

  void setTheme(AppTheme t) {
    _theme = t;
    String key = 'dark';
    if (t == AppTheme.light) key = 'light';
    if (t == AppTheme.system) key = 'system';
    StorageService.saveTheme(key);
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.system:
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  // ─── Light ThemeData ─────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: kFont,
    scaffoldBackgroundColor: kLightBg,
    colorScheme: const ColorScheme.light(
      primary: kLightPrimary,
      secondary: kLightAccent,
      surface: kLightDisplay,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kLightBg,
      foregroundColor: kLightPrimary,
      elevation: 0,
    ),
  );

  // ─── Dark ThemeData ──────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: kFont,
    scaffoldBackgroundColor: kDarkBg,
    colorScheme: const ColorScheme.dark(
      primary: kDarkPrimary,
      secondary: kDarkAccent,
      surface: kDarkDisplay,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kDarkBg,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
