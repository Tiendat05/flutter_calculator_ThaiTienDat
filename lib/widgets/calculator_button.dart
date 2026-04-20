import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum ButtonType { number, operator, function, special, equals, clear }

class CalculatorButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonType type;
  final double? fontSize;
  final bool isWide;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.number,
    this.fontSize,
    this.isWide = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: kButtonPressDuration);
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) {
    _ctrl.reverse();
    widget.onPressed();
  }

  void _onCancel() => _ctrl.reverse();

  Color _bgColor(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    switch (widget.type) {
      case ButtonType.clear:
        return isDark ? const Color(0xFF8B2121) : const Color(0xFFFFCDD2);
      case ButtonType.operator:
        return isDark ? const Color(0xFF2C4A3E) : const Color(0xFFE8F5E9);
      case ButtonType.equals:
        return isDark ? kDarkAccent : kLightAccent;
      case ButtonType.function:
        return isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE3F2FD);
      case ButtonType.special:
        return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
      default:
        return isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF);
    }
  }

  Color _textColor(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    switch (widget.type) {
      case ButtonType.clear:
        return isDark ? const Color(0xFFFF8A80) : const Color(0xFFD32F2F);
      case ButtonType.operator:
        return isDark ? kDarkAccent : const Color(0xFF2E7D32);
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.function:
        return isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0);
      default:
        return isDark ? Colors.white : const Color(0xFF1E1E1E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.all(kButtonSpacing / 2),
          decoration: BoxDecoration(
            color: _bgColor(context),
            borderRadius: BorderRadius.circular(kButtonRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.fontSize ?? kButtonFontSize,
                color: _textColor(context),
                fontWeight: FontWeight.w500,
                fontFamily: kFont,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
