// Model for calculator mode
enum CalculatorMode { basic, scientific, programmer }

extension CalculatorModeExtension on CalculatorMode {
  String get displayName {
    switch (this) {
      case CalculatorMode.basic:
        return 'Basic';
      case CalculatorMode.scientific:
        return 'Scientific';
      case CalculatorMode.programmer:
        return 'Programmer';
    }
  }

  String get storageKey {
    switch (this) {
      case CalculatorMode.basic:
        return 'basic';
      case CalculatorMode.scientific:
        return 'scientific';
      case CalculatorMode.programmer:
        return 'programmer';
    }
  }

  static CalculatorMode fromString(String s) {
    switch (s) {
      case 'scientific':
        return CalculatorMode.scientific;
      case 'programmer':
        return CalculatorMode.programmer;
      default:
        return CalculatorMode.basic;
    }
  }
}

enum AngleMode { deg, rad }

extension AngleModeExtension on AngleMode {
  String get label => this == AngleMode.deg ? 'DEG' : 'RAD';
}
