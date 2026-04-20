import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';
import '../utils/constants.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? kDarkAccent : kLightAccent;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: kScreenPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: CalculatorMode.values.map((mode) {
          final selected = provider.mode == mode;
          return Expanded(
            child: AnimatedContainer(
              duration: kModeSwitchDuration,
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => provider.setMode(mode),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    mode.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.grey : Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
