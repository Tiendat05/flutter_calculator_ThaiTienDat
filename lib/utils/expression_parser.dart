import 'dart:math' as math;

class ExpressionParser {
  static bool _isRadMode = false;

  static void setAngleMode(bool isRad) {
    _isRadMode = isRad;
  }

  // ─── Entry point ──────────────────────────────────────────────
  static String evaluate(String expression, {int precision = 6}) {
    try {
      final prepared = _prepare(expression);
      final result = _Parser(prepared).parse();

      if (result.isNaN || result.isInfinite) return 'Error';

      if (result == result.roundToDouble()) {
        final asInt = result.toInt();
        if (asInt.abs() < 1e15) return asInt.toString();
      }

      final fixed = result.toStringAsFixed(precision);
      return fixed
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    } catch (_) {
      return 'Error';
    }
  }

  // ─── Pre-process ─────────────────────────────────────────────
  static String _prepare(String expr) {
    String e = expr
        .replaceAll('x', '*')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', '${math.pi}')
        .replaceAll('%', '/100');

    // Thay 'e' hằng số (chỉ đứng một mình)
    e = e.replaceAllMapped(
      RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z0-9])'),
      (_) => '${math.e}',
    );

    // Implicit multiplication
    e = e.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Z(])'),
      (m) => '${m[1]}*${m[2]}',
    );
    e = e.replaceAllMapped(RegExp(r'(\))(\d)'), (m) => '${m[1]}*${m[2]}');
    e = e.replaceAllMapped(RegExp(r'(\))(\()'), (m) => '${m[1]}*${m[2]}');

    // Đóng ngoặc còn thiếu
    final open = '('.allMatches(e).length;
    final close = ')'.allMatches(e).length;
    for (int i = 0; i < open - close; i++) e += ')';

    return e;
  }

  // ─── Hàm toán học (public để _Parser dùng được) ──────────────
  static bool isFunctionName(String t) {
    const fns = [
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'ln',
      'log',
      'log2',
      'sqrt',
      'cbrt',
      'abs',
      'fact',
    ];
    return fns.contains(t.toLowerCase());
  }

  static double applyFunction(String name, double arg) {
    final a = _toRad(name, arg);
    switch (name.toLowerCase()) {
      case 'sin':
        return math.sin(a);
      case 'cos':
        return math.cos(a);
      case 'tan':
        if ((a - math.pi / 2).abs() < 1e-10) throw Exception('Undefined');
        return math.tan(a);
      case 'asin':
        return _fromRad(math.asin(arg));
      case 'acos':
        return _fromRad(math.acos(arg));
      case 'atan':
        return _fromRad(math.atan(arg));
      case 'ln':
        return math.log(arg);
      case 'log':
        return math.log(arg) / math.ln10;
      case 'log2':
        return math.log(arg) / math.log2e;
      case 'sqrt':
        if (arg < 0) throw Exception('Sqrt of negative');
        return math.sqrt(arg);
      case 'cbrt':
        return arg < 0
            ? -math.pow(-arg, 1 / 3).toDouble()
            : math.pow(arg, 1 / 3).toDouble();
      case 'abs':
        return arg.abs();
      case 'fact':
        return _factorial(arg.toInt()).toDouble();
      default:
        throw Exception('Unknown function $name');
    }
  }

  static double _toRad(String fn, double val) {
    const trigFns = ['sin', 'cos', 'tan'];
    if (!_isRadMode && trigFns.contains(fn.toLowerCase())) {
      return val * math.pi / 180;
    }
    return val;
  }

  static double _fromRad(double val) {
    return _isRadMode ? val : val * 180 / math.pi;
  }

  static int _factorial(int n) {
    if (n < 0) throw Exception('Negative factorial');
    if (n > 20) throw Exception('Too large');
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  // ─── Programmer mode ─────────────────────────────────────────
  static String evaluateProgrammer(String expr) {
    try {
      String e = expr
          .replaceAll(' AND ', '&')
          .replaceAll(' OR ', '|')
          .replaceAll(' XOR ', '\x00') // placeholder tránh xung đột ^
          .replaceAll(' NOT ', '~');

      e = e.replaceAllMapped(
        RegExp(r'0x([0-9A-Fa-f]+)'),
        (m) => int.parse(m[1]!, radix: 16).toString(),
      );
      e = e.replaceAllMapped(
        RegExp(r'0b([01]+)'),
        (m) => int.parse(m[1]!, radix: 2).toString(),
      );
      e = e.replaceAllMapped(
        RegExp(r'0o([0-7]+)'),
        (m) => int.parse(m[1]!, radix: 8).toString(),
      );

      e = e.replaceAll('\x00', '^');

      final result = _Parser(e).parse().toInt();
      return result.toString();
    } catch (_) {
      return 'Error';
    }
  }

  static String toBinary(int n) => n.toRadixString(2);
  static String toOctal(int n) => n.toRadixString(8);
  static String toHex(int n) => '0x${n.toRadixString(16).toUpperCase()}';
}

// ─── _Parser: tách class riêng để tránh lỗi forward reference ────
// Trong Dart, local functions không thể tham chiếu nhau theo thứ tự bất kỳ,
// nhưng class methods thì có thể — Dart resolve lúc runtime.
class _Parser {
  final List<String> _tokens;
  int _pos = 0;

  _Parser(String expr) : _tokens = _tokenize(expr);

  double parse() => _parseAddSub();

  // ── Tokenizer ────────────────────────────────────────────────
  static List<String> _tokenize(String expr) {
    final tokens = <String>[];
    int i = 0;
    while (i < expr.length) {
      final ch = expr[i];

      if (ch == ' ') {
        i++;
        continue;
      }

      if (RegExp(r'[\d.]').hasMatch(ch)) {
        int j = i;
        while (j < expr.length && RegExp(r'[\d.]').hasMatch(expr[j])) j++;
        tokens.add(expr.substring(i, j));
        i = j;
        continue;
      }

      if (RegExp(r'[a-zA-Z_]').hasMatch(ch)) {
        int j = i;
        while (j < expr.length && RegExp(r'[a-zA-Z_0-9]').hasMatch(expr[j]))
          j++;
        tokens.add(expr.substring(i, j));
        i = j;
        continue;
      }

      // Unary minus
      if (ch == '-' &&
          (tokens.isEmpty ||
              ['+', '-', '*', '/', '^', '('].contains(tokens.last))) {
        tokens.add('-');
        i++;
        continue;
      }

      tokens.add(ch);
      i++;
    }
    return tokens;
  }

  // ── Grammar ──────────────────────────────────────────────────
  double _parseAddSub() {
    double left = _parseMulDiv();
    while (_pos < _tokens.length &&
        (_tokens[_pos] == '+' || _tokens[_pos] == '-')) {
      final op = _tokens[_pos++];
      final right = _parseMulDiv();
      left = op == '+' ? left + right : left - right;
    }
    return left;
  }

  double _parseMulDiv() {
    double left = _parsePow();
    while (_pos < _tokens.length &&
        (_tokens[_pos] == '*' || _tokens[_pos] == '/')) {
      final op = _tokens[_pos++];
      final right = _parsePow();
      if (op == '/') {
        if (right == 0) throw Exception('Division by zero');
        left = left / right;
      } else {
        left = left * right;
      }
    }
    return left;
  }

  double _parsePow() {
    double base = _parseUnary();
    if (_pos < _tokens.length && _tokens[_pos] == '^') {
      _pos++;
      final exp = _parseUnary();
      return math.pow(base, exp).toDouble();
    }
    return base;
  }

  double _parseUnary() {
    if (_pos < _tokens.length && _tokens[_pos] == '-') {
      _pos++;
      return -_parseUnary();
    }
    if (_pos < _tokens.length && _tokens[_pos] == '+') {
      _pos++;
    }
    return _parsePrimary();
  }

  double _parsePrimary() {
    if (_pos >= _tokens.length) throw Exception('Unexpected end');

    final token = _tokens[_pos];

    final asNum = double.tryParse(token);
    if (asNum != null) {
      _pos++;
      return asNum;
    }

    if (token == '(') {
      _pos++;
      final val = _parseAddSub();
      if (_pos < _tokens.length && _tokens[_pos] == ')') _pos++;
      return val;
    }

    if (ExpressionParser.isFunctionName(token)) {
      _pos++;
      if (_pos >= _tokens.length || _tokens[_pos] != '(') {
        throw Exception('Expected ( after $token');
      }
      _pos++;
      final arg = _parseAddSub();
      if (_pos < _tokens.length && _tokens[_pos] == ')') _pos++;
      return ExpressionParser.applyFunction(token, arg);
    }

    throw Exception('Unknown token: $token');
  }
}
