class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;
  final String mode; // 'basic', 'scientific', 'programmer'

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
    required this.mode,
  });

  // Chuyển thành String để lưu SharedPreferences
  String toStorageString() {
    return '$expression|$result|${timestamp.toIso8601String()}|$mode';
  }

  // Khôi phục từ String đã lưu
  static CalculationHistory? fromStorageString(String s) {
    final parts = s.split('|');
    if (parts.length < 4) return null;
    return CalculationHistory(
      expression: parts[0],
      result: parts[1],
      timestamp: DateTime.tryParse(parts[2]) ?? DateTime.now(),
      mode: parts[3],
    );
  }

  String get displayString => '$expression = $result';
}
