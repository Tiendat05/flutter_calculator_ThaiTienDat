import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 🎨 COLORS (Figma)
const Color primary = Color(0xFF2D3142);
const Color secondary = Color(0xFF4F5D75);
const Color accent = Color(0xFFEF8354);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorUI(),
    );
  }
}

class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> {
  String display = '0';
  String equation = '';
  double num1 = 0;
  double num2 = 0;
  String operation = '';

  void onButtonPressed(String value) {
    setState(() {
      // RESET
      if (value == 'C') {
        display = '0';
        equation = ' ';
        num1 = 0;
        num2 = 0;
        operation = '';
      }
      // PHÉP TOÁN
      else if (['+', '-', '×', '÷'].contains(value)) {
        num1 = double.parse(display);
        operation = value;
        equation = '$display $value';
        display = '0';
      }
      // =
      else if (value == '=') {
        num2 = double.parse(display);

        if (operation == '+') {
          display = (num1 + num2).toString();
        } else if (operation == '-') {
          display = (num1 - num2).toString();
        } else if (operation == '×') {
          display = (num1 * num2).toString();
        } else if (operation == '÷') {
          display = num2 == 0 ? 'Error' : (num1 / num2).toString();
        }
        equation = '$num1 $operation $num2 =';
      }
      // +/- đổi dấu
      else if (value == '+/-') {
        if (display.startsWith('-')) {
          display = display.substring(1);
        } else if (display != '0') {
          display = '-$display';
        }
      }
      // %
      else if (value == '%') {
        double num = double.parse(display);
        display = (num / 100).toString();
      }
      // .
      else if (value == '.') {
        if (!display.contains('.')) {
          display += '.';
        }
      }
      // SỐ
      else if (RegExp(r'^[0-9]$').hasMatch(value)) {
        if (display == '0') {
          display = value;
        } else {
          display += value;
        }
        equation = equation.isEmpty ? display : equation;
      }
    });
  }

  Widget buildRow(List<String> texts) {
    return Expanded(
      child: Row(children: texts.map((e) => buildButton(e)).toList()),
    );
  }

  Widget buildButton(String text) {
    Color bgColor;

    if (text == 'C') {
      bgColor = Colors.red;
    } else if (['÷', '×', '-', '+', '='].contains(text)) {
      bgColor = accent;
    } else {
      bgColor = secondary;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            onPressed: () => onButtonPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              shape: const CircleBorder(),
              elevation: 0,
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        child: Column(
          children: [
            //  DISPLAY
            Expanded(
              flex: 43,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    width: 160,
                    height: 77,
                    child: FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        display,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // BUTTONS
            Expanded(
              flex: 57,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildRow(['C', '( )', '%', '÷']),
                    buildRow(['7', '8', '9', '×']),
                    buildRow(['4', '5', '6', '-']),
                    buildRow(['1', '2', '3', '+']),
                    buildRow(['+/-', '0', '.', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
