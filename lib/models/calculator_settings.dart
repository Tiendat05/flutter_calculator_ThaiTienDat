// Model for calculator settings
class CalculatorSettings {
  final int decimalPrecision; // 2–10
  final bool hapticFeedback;
  final bool soundEffects;
  final int historySize; // 25, 50, 100

  const CalculatorSettings({
    this.decimalPrecision = 6,
    this.hapticFeedback = true,
    this.soundEffects = false,
    this.historySize = 50,
  });

  CalculatorSettings copyWith({
    int? decimalPrecision,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
  }) {
    return CalculatorSettings(
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
    );
  }
}
