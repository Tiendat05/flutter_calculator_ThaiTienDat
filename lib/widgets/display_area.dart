import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';
import '../utils/constants.dart';

class DisplayArea extends StatelessWidget {
  const DisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final display = provider.display;
    final isLong = display.length > 10;
    final isVLong = display.length > 16;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        kScreenPadding,
        16,
        kScreenPadding,
        12,
      ),
      decoration: BoxDecoration(
        color: isDark ? kDarkDisplay : kLightDisplay,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(kDisplayRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Top indicators ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mode + angle indicators
              Row(
                children: [
                  _Pill(label: provider.mode.displayName, isDark: isDark),
                  if (provider.mode == CalculatorMode.scientific) ...[
                    const SizedBox(width: 6),
                    _Pill(
                      label: provider.angleMode.label,
                      isDark: isDark,
                      isAccent: true,
                    ),
                  ],
                  if (provider.hasMemory) ...[
                    const SizedBox(width: 6),
                    _Pill(label: 'M', isDark: isDark, isAccent: true),
                  ],
                ],
              ),
              // Error indicator
              if (provider.hasError)
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Previous result (dimmed) ─────────────────────────
          if (provider.prevResult.isNotEmpty)
            Text(
              provider.prevResult,
              style: TextStyle(
                fontSize: 18,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.35),
                fontFamily: kFont,
                fontWeight: FontWeight.w300,
              ),
            ),

          const SizedBox(height: 4),

          // ── Main display ─────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              display,
              key: ValueKey(display),
              style: TextStyle(
                fontSize: isVLong
                    ? 24
                    : isLong
                    ? 36
                    : kDisplayFontSize * 1.5,
                color: provider.hasError
                    ? Colors.redAccent
                    : (isDark ? Colors.white : const Color(0xFF1E1E1E)),
                fontFamily: kFont,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          // ── Programmer mode: hex/bin/oct conversions ─────────
          if (provider.mode == CalculatorMode.programmer) ...[
            const Divider(height: 1),
            const SizedBox(height: 6),
            _ConvRow(label: 'HEX', value: provider.hexDisplay, isDark: isDark),
            _ConvRow(
              label: 'BIN',
              value: provider.binaryDisplay,
              isDark: isDark,
            ),
            _ConvRow(
              label: 'OCT',
              value: provider.octalDisplay,
              isDark: isDark,
            ),
          ],

          // ── Recent history preview (swipeable, last 3) ───────
          if (provider.recentHistory.isNotEmpty &&
              provider.mode != CalculatorMode.programmer)
            _HistoryPreview(provider: provider, isDark: isDark),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool isAccent;
  const _Pill({
    required this.label,
    required this.isDark,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? kDarkAccent : kLightAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAccent ? accent.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: isAccent ? accent : Colors.grey.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isAccent ? accent : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ConvRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _ConvRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPreview extends StatelessWidget {
  final CalculatorProvider provider;
  final bool isDark;
  const _HistoryPreview({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Divider(height: 16),
        ...provider.recentHistory.map(
          (item) => GestureDetector(
            onTap: () => provider.reuseHistoryResult(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                item.displayString,
                style: TextStyle(
                  fontSize: kHistoryFontSize * 0.8,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.3,
                  ),
                  fontFamily: kFont,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
