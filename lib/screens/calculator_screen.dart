import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';
import '../widgets/mode_selector.dart';
import '../utils/constants.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          // Swipe right on display → backspace
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 0) {
              provider.onButtonPressed('⌫');
            }
          },
          // Swipe up → open history
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -200) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            }
          },
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPadding,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // History button
                    IconButton(
                      icon: const Icon(Icons.history_rounded),
                      tooltip: 'Lịch sử',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      ),
                    ),
                    // Settings button
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Cài đặt',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Display ──────────────────────────────────────
              const DisplayArea(),

              // ── Mode selector ─────────────────────────────────
              const ModeSelector(),

              // ── Button grid ───────────────────────────────────
              const Expanded(child: ButtonGrid()),
            ],
          ),
        ),
      ),
    );
  }
}
