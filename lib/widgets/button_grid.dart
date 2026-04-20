import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';
import '../utils/constants.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatefulWidget {
  const ButtonGrid({super.key});

  @override
  State<ButtonGrid> createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  bool _showSecond = false; // 2nd function toggle

  // ─── Basic Mode layout ───────────────────────────────────────
  List<List<_BtnDef>> get _basicButtons => [
    [
      _BtnDef('C', ButtonType.clear),
      _BtnDef('CE', ButtonType.special),
      _BtnDef('%', ButtonType.function),
      _BtnDef('÷', ButtonType.operator),
    ],
    [
      _BtnDef('7', ButtonType.number),
      _BtnDef('8', ButtonType.number),
      _BtnDef('9', ButtonType.number),
      _BtnDef('×', ButtonType.operator),
    ],
    [
      _BtnDef('4', ButtonType.number),
      _BtnDef('5', ButtonType.number),
      _BtnDef('6', ButtonType.number),
      _BtnDef('−', ButtonType.operator),
    ],
    [
      _BtnDef('1', ButtonType.number),
      _BtnDef('2', ButtonType.number),
      _BtnDef('3', ButtonType.number),
      _BtnDef('+', ButtonType.operator),
    ],
    [
      _BtnDef('+/-', ButtonType.special),
      _BtnDef('0', ButtonType.number),
      _BtnDef('.', ButtonType.number),
      _BtnDef('=', ButtonType.equals),
    ],
  ];

  // ─── Scientific Mode layout ──────────────────────────────────
  List<List<_BtnDef>> get _sciButtons {
    return [
      [
        _BtnDef('2nd', ButtonType.special),
        _BtnDef(_showSecond ? 'asin' : 'sin', ButtonType.function),
        _BtnDef(_showSecond ? 'acos' : 'cos', ButtonType.function),
        _BtnDef(_showSecond ? 'atan' : 'tan', ButtonType.function),
        _BtnDef('Ln', ButtonType.function),
        _BtnDef('log', ButtonType.function),
      ],
      [
        _BtnDef(_showSecond ? 'x³' : 'x²', ButtonType.function),
        _BtnDef(_showSecond ? '∛' : '√', ButtonType.function),
        _BtnDef('x^y', ButtonType.function),
        _BtnDef('(', ButtonType.special),
        _BtnDef(')', ButtonType.special),
        _BtnDef('÷', ButtonType.operator),
      ],
      [
        _BtnDef('MC', ButtonType.special),
        _BtnDef('7', ButtonType.number),
        _BtnDef('8', ButtonType.number),
        _BtnDef('9', ButtonType.number),
        _BtnDef('C', ButtonType.clear),
        _BtnDef('×', ButtonType.operator),
      ],
      [
        _BtnDef('MR', ButtonType.special),
        _BtnDef('4', ButtonType.number),
        _BtnDef('5', ButtonType.number),
        _BtnDef('6', ButtonType.number),
        _BtnDef('CE', ButtonType.special),
        _BtnDef('−', ButtonType.operator),
      ],
      [
        _BtnDef('M+', ButtonType.special),
        _BtnDef('1', ButtonType.number),
        _BtnDef('2', ButtonType.number),
        _BtnDef('3', ButtonType.number),
        _BtnDef('%', ButtonType.function),
        _BtnDef('+', ButtonType.operator),
      ],
      [
        _BtnDef('M-', ButtonType.special),
        _BtnDef('+/-', ButtonType.special),
        _BtnDef('0', ButtonType.number),
        _BtnDef('.', ButtonType.number),
        _BtnDef('π', ButtonType.function),
        _BtnDef('=', ButtonType.equals),
      ],
    ];
  }

  // ─── Programmer Mode layout ──────────────────────────────────
  List<List<_BtnDef>> get _progButtons => [
    [
      _BtnDef('C', ButtonType.clear),
      _BtnDef('AND', ButtonType.function),
      _BtnDef('OR', ButtonType.function),
      _BtnDef('XOR', ButtonType.function),
    ],
    [
      _BtnDef('<<', ButtonType.function),
      _BtnDef('>>', ButtonType.function),
      _BtnDef('NOT', ButtonType.function),
      _BtnDef('÷', ButtonType.operator),
    ],
    [
      _BtnDef('7', ButtonType.number),
      _BtnDef('8', ButtonType.number),
      _BtnDef('9', ButtonType.number),
      _BtnDef('×', ButtonType.operator),
    ],
    [
      _BtnDef('4', ButtonType.number),
      _BtnDef('5', ButtonType.number),
      _BtnDef('6', ButtonType.number),
      _BtnDef('−', ButtonType.operator),
    ],
    [
      _BtnDef('1', ButtonType.number),
      _BtnDef('2', ButtonType.number),
      _BtnDef('3', ButtonType.number),
      _BtnDef('+', ButtonType.operator),
    ],
    [
      _BtnDef('⌫', ButtonType.special),
      _BtnDef('0', ButtonType.number),
      _BtnDef('.', ButtonType.number),
      _BtnDef('=', ButtonType.equals),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    List<List<_BtnDef>> layout;
    switch (provider.mode) {
      case CalculatorMode.scientific:
        layout = _sciButtons;
        break;
      case CalculatorMode.programmer:
        layout = _progButtons;
        break;
      default:
        layout = _basicButtons;
    }

    final cols = layout.first.length;

    return AnimatedSwitcher(
      duration: kModeSwitchDuration,
      child: Padding(
        key: ValueKey(provider.mode),
        padding: const EdgeInsets.fromLTRB(
          kScreenPadding / 2,
          0,
          kScreenPadding / 2,
          kScreenPadding,
        ),
        child: Column(
          children: layout.map((row) {
            return Expanded(
              child: Row(
                children: row.map((def) {
                  return Expanded(
                    child: CalculatorButton(
                      label: def.label,
                      type: def.type,
                      fontSize: cols > 4 ? 13 : kButtonFontSize,
                      onPressed: () {
                        if (def.label == '2nd') {
                          setState(() => _showSecond = !_showSecond);
                        } else if (def.label == 'AND') {
                          provider.onButtonPressed(' AND ');
                        } else if (def.label == 'OR') {
                          provider.onButtonPressed(' OR ');
                        } else if (def.label == 'XOR') {
                          provider.onButtonPressed(' XOR ');
                        } else if (def.label == 'NOT') {
                          provider.onButtonPressed(' NOT ');
                        } else {
                          provider.onButtonPressed(def.label);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BtnDef {
  final String label;
  final ButtonType type;
  const _BtnDef(this.label, this.type);
}
