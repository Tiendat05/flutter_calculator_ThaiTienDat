import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import '../utils/expression_parser.dart';
import '../utils/calculator_logic.dart';
import '../services/storage_service.dart';
export 'calculator_provider.dart';

class CalculatorProvider extends ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────
  String _expression = '';
  String _display = '0';
  String _prevResult = '';
  bool _justEvaled = false;
  bool _hasError = false;

  // Memory
  double _memory = 0.0;
  bool _hasMemory = false;

  // Mode & settings
  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.deg;
  CalculatorSettings _settings = const CalculatorSettings();

  // History
  List<CalculationHistory> _history = [];

  // ─── Getters ─────────────────────────────────────────────────
  String get display => _display;
  String get expression => _expression;
  String get prevResult => _prevResult;
  bool get hasError => _hasError;
  bool get hasMemory => _hasMemory;
  double get memory => _memory;

  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  CalculatorSettings get settings => _settings;

  List<CalculationHistory> get history => _history;
  List<CalculationHistory> get recentHistory =>
      _history.reversed.take(3).toList();

  // Programmer mode conversions
  int get currentInt => int.tryParse(_display) ?? 0;
  String get binaryDisplay => ExpressionParser.toBinary(currentInt);
  String get octalDisplay => ExpressionParser.toOctal(currentInt);
  String get hexDisplay => ExpressionParser.toHex(currentInt);

  // ─── Constructor ─────────────────────────────────────────────
  CalculatorProvider() {
    _init();
  }

  Future<void> _init() async {
    _history = await StorageService.loadHistory();
    _memory = await StorageService.loadMemory();
    _hasMemory = _memory != 0.0;

    final saved = await StorageService.loadMode();
    _mode = CalculatorModeExtension.fromString(saved);

    final isRad = await StorageService.loadAngleMode();
    _angleMode = isRad ? AngleMode.rad : AngleMode.deg;
    ExpressionParser.setAngleMode(isRad);

    final s = await StorageService.loadSettings();
    _settings = CalculatorSettings(
      decimalPrecision: s['precision'],
      hapticFeedback: s['haptic'],
      soundEffects: s['sound'],
      historySize: s['historySize'],
    );

    notifyListeners();
  }

  // ─── Button handler ───────────────────────────────────────────
  void onButtonPressed(String value) {
    if (_settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    switch (value) {
      case 'C':
        _clear();
        break;
      case 'CE':
        _clearEntry();
        break;
      case '⌫':
        _backspace();
        break;
      case '=':
        _evaluate();
        break;
      case '+/-':
        _toggleSign();
        break;
      case '()':
        _handleParen();
        break;
      case 'MC':
        _memoryClear();
        break;
      case 'MR':
        _memoryRecall();
        break;
      case 'M+':
        _memoryAdd();
        break;
      case 'M-':
        _memorySub();
        break;
      case 'DEG':
      case 'RAD':
        _toggleAngle();
        break;
      default:
        _appendValue(value);
    }

    notifyListeners();
  }

  // ─── Core operations ─────────────────────────────────────────
  void _clear() {
    _expression = '';
    _display = '0';
    _prevResult = '';
    _justEvaled = false;
    _hasError = false;
  }

  void _clearEntry() {
    _display = '0';
    _hasError = false;
  }

  void _backspace() {
    if (_hasError) {
      _clear();
      return;
    }
    if (_justEvaled) {
      _clear();
      return;
    }
    _display = CalculatorLogic.backspace(_display);
    _expression = _expression.isEmpty
        ? ''
        : CalculatorLogic.backspace(_expression);
  }

  void _evaluate() {
    if (_hasError) return;
    final expr = _display.isNotEmpty ? _display : _expression;
    if (!CalculatorLogic.canEvaluate(expr)) return;

    String result;
    if (_mode == CalculatorMode.programmer) {
      result = ExpressionParser.evaluateProgrammer(expr);
    } else {
      result = ExpressionParser.evaluate(
        expr,
        precision: _settings.decimalPrecision,
      );
    }

    if (result == 'Error') {
      _hasError = true;
      _display = 'Error';
      _prevResult = '';
    } else {
      // Lưu lịch sử
      final item = CalculationHistory(
        expression: expr,
        result: result,
        timestamp: DateTime.now(),
        mode: _mode.storageKey,
      );
      _history.add(item);
      StorageService.saveHistory(_history, limit: _settings.historySize);

      _prevResult = _display;
      _display = result;
      _expression = result;
      _justEvaled = true;
      _hasError = false;
    }
  }

  void _appendValue(String val) {
    if (_hasError) return;

    // Nếu vừa tính xong và bấm số → bắt đầu lại
    if (_justEvaled && RegExp(r'[\d\.]').hasMatch(val)) {
      _expression = '';
      _display = '0';
      _prevResult = _display;
      _justEvaled = false;
    }
    // Nếu vừa tính xong và bấm operator → tiếp tục từ kết quả
    if (_justEvaled && ['+', '−', '×', '÷'].contains(val)) {
      _justEvaled = false;
    }

    final operators = ['+', '−', '×', '÷'];
    if (operators.contains(val)) {
      _display = CalculatorLogic.replaceLastOperator(_display, val);
    } else if (val == '.') {
      // Chỉ thêm dấu chấm nếu segment hiện tại chưa có
      final segments = _display.split(RegExp(r'[\+\−\×\÷\(\)]'));
      final lastSeg = segments.last;
      if (!lastSeg.contains('.')) _display += '.';
    } else {
      // Hàm scientific (sin, cos, ...)
      if (_isScientificFunc(val)) {
        _display += '$val(';
      } else if (val == 'x²') {
        _display += '^2';
      } else if (val == 'x³') {
        _display += '^3';
      } else if (val == 'x^y') {
        _display += '^';
      } else if (val == '√') {
        _display += 'sqrt(';
      } else if (val == '∛') {
        _display += 'cbrt(';
      } else if (val == 'n!') {
        _display += 'fact(';
      } else if (val == 'π') {
        _display += 'π';
      } else if (val == 'Ln') {
        _display += 'ln(';
      } else if (val == 'log') {
        _display += 'log(';
      } else if (val == '2nd') {
        // Toggle 2nd — handled by UI
      } else {
        if (_display == '0') {
          _display = val;
        } else {
          _display += val;
        }
      }
    }
    _justEvaled = false;
  }

  bool _isScientificFunc(String v) =>
      ['sin', 'cos', 'tan', 'asin', 'acos', 'atan'].contains(v.toLowerCase());

  void _toggleSign() {
    _display = CalculatorLogic.toggleSign(_display);
  }

  void _handleParen() {
    _display = CalculatorLogic.handleParenthesis(_display);
    _justEvaled = false;
  }

  // ─── Memory ──────────────────────────────────────────────────
  void _memoryClear() {
    _memory = 0.0;
    _hasMemory = false;
    StorageService.saveMemory(0.0);
  }

  void _memoryRecall() {
    _display = _memory % 1 == 0
        ? _memory.toInt().toString()
        : _memory.toString();
    _justEvaled = false;
  }

  void _memoryAdd() {
    final val = double.tryParse(_display) ?? 0.0;
    _memory += val;
    _hasMemory = _memory != 0.0;
    StorageService.saveMemory(_memory);
  }

  void _memorySub() {
    final val = double.tryParse(_display) ?? 0.0;
    _memory -= val;
    _hasMemory = _memory != 0.0;
    StorageService.saveMemory(_memory);
  }

  // ─── Mode switching ──────────────────────────────────────────
  void setMode(CalculatorMode newMode) {
    _mode = newMode;
    StorageService.saveMode(newMode.storageKey);
    _clear();
    notifyListeners();
  }

  void _toggleAngle() {
    _angleMode = _angleMode == AngleMode.deg ? AngleMode.rad : AngleMode.deg;
    ExpressionParser.setAngleMode(_angleMode == AngleMode.rad);
    StorageService.saveAngleMode(_angleMode == AngleMode.rad);
  }

  // ─── History ─────────────────────────────────────────────────
  void clearHistory() {
    _history.clear();
    StorageService.clearHistory();
    notifyListeners();
  }

  void reuseHistoryResult(CalculationHistory item) {
    _display = item.result;
    _expression = item.result;
    _justEvaled = true;
    notifyListeners();
  }

  // ─── Settings ────────────────────────────────────────────────
  void updateSettings(CalculatorSettings newSettings) {
    _settings = newSettings;
    StorageService.saveSettings(
      precision: newSettings.decimalPrecision,
      haptic: newSettings.hapticFeedback,
      sound: newSettings.soundEffects,
      historySize: newSettings.historySize,
    );
    notifyListeners();
  }
}
