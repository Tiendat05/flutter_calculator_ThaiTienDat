import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calcProvider = context.watch<CalculatorProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final settings = calcProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(kScreenPadding),
        children: [
          // ── Theme ─────────────────────────────────────────────
          _SectionHeader('Giao diện'),
          _SegmentedRow(
            label: 'Chủ đề',
            options: const ['Sáng', 'Tối', 'Hệ thống'],
            selected: themeProvider.theme.index,
            onChanged: (i) => themeProvider.setTheme(AppTheme.values[i]),
          ),
          const Divider(height: 24),

          // ── Calculation ───────────────────────────────────────
          _SectionHeader('Tính toán'),
          _SliderRow(
            label: 'Số chữ số thập phân',
            value: settings.decimalPrecision.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            display: '${settings.decimalPrecision}',
            onChanged: (v) => calcProvider.updateSettings(
              settings.copyWith(decimalPrecision: v.round()),
            ),
          ),
          const Divider(height: 24),

          // ── Feedback ──────────────────────────────────────────
          _SectionHeader('Phản hồi'),
          _SwitchRow(
            label: 'Rung khi bấm nút',
            value: settings.hapticFeedback,
            onChanged: (v) => calcProvider.updateSettings(
              settings.copyWith(hapticFeedback: v),
            ),
          ),
          _SwitchRow(
            label: 'Âm thanh',
            value: settings.soundEffects,
            onChanged: (v) =>
                calcProvider.updateSettings(settings.copyWith(soundEffects: v)),
          ),
          const Divider(height: 24),

          // ── History ───────────────────────────────────────────
          _SectionHeader('Lịch sử'),
          _SegmentedRow(
            label: 'Lưu tối đa',
            options: const ['25', '50', '100'],
            selected: [25, 50, 100].indexOf(settings.historySize),
            onChanged: (i) => calcProvider.updateSettings(
              settings.copyWith(historySize: [25, 50, 100][i]),
            ),
          ),
          const SizedBox(height: 16),

          // Clear history button
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            label: const Text(
              'Xóa toàn bộ lịch sử',
              style: TextStyle(color: Colors.redAccent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => _confirmClearHistory(context, calcProvider),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Advanced Calculator v1.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, CalculatorProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Toàn bộ lịch sử tính toán sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 15)),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}

class _SliderRow extends StatelessWidget {
  final String label, display;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            Text(
              display,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: isDarkMode ? Colors.white70 : null,
            inactiveTrackColor: isDarkMode ? Colors.white24 : null,
            thumbColor: isDarkMode ? Colors.white : null,
            overlayColor: isDarkMode ? Colors.white30 : null,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  const _SegmentedRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 15)),
      SegmentedButton<int>(
        segments: options
            .asMap()
            .entries
            .map(
              (e) => ButtonSegment<int>(
                value: e.key,
                label: Text(e.value, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
        showSelectedIcon: false,
      ),
    ],
  );
}
