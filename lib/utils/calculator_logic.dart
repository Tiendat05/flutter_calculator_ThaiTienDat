// Tách logic xử lý input button ra khỏi Provider để dễ test
class CalculatorLogic {
  // Kiểm tra ký tự cuối có phải operator không
  static bool endsWithOperator(String expr) {
    if (expr.isEmpty) return false;
    return ['+', '-', '×', '÷', '('].contains(expr[expr.length - 1]);
  }

  // Xử lý thêm ký tự vào biểu thức
  static String appendToExpression(String current, String value) {
    // Bắt đầu mới sau kết quả
    if (current == '0' && !['.', '+', '-', '×', '÷'].contains(value)) {
      return value;
    }
    return current + value;
  }

  // Thay operator cuối nếu người dùng bấm operator khác liên tiếp
  static String replaceLastOperator(String expr, String newOp) {
    if (endsWithOperator(expr) && newOp != '(') {
      return expr.substring(0, expr.length - 1) + newOp;
    }
    return expr + newOp;
  }

  // Xóa ký tự cuối
  static String backspace(String expr) {
    if (expr.isEmpty || expr == '0') return '0';
    final result = expr.substring(0, expr.length - 1);
    return result.isEmpty ? '0' : result;
  }

  // Toggle dấu
  static String toggleSign(String expr) {
    if (expr == '0' || expr.isEmpty) return expr;
    if (expr.startsWith('-')) return expr.substring(1);
    return '-$expr';
  }

  // Kiểm tra biểu thức có hợp lệ để tính không
  static bool canEvaluate(String expr) {
    if (expr.isEmpty || expr == '0') return false;
    if (endsWithOperator(expr)) return false;
    return true;
  }

  // Đếm ngoặc để quyết định thêm ( hay )
  static String handleParenthesis(String expr) {
    int openCount = '('.allMatches(expr).length;
    int closeCount = ')'.allMatches(expr).length;

    if (expr.isEmpty || endsWithOperator(expr)) {
      return '$expr(';
    }
    if (openCount > closeCount) {
      return '$expr)';
    }
    return '$expr×(';
  }
}
