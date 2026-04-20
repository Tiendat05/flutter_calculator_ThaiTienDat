import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculation_history.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final history = provider.history.reversed.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch sử',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          if (history.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Xóa tất cả'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              onPressed: () => _confirmClear(context, provider),
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmpty(isDark)
          : ListView.separated(
              padding: const EdgeInsets.all(kScreenPadding),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _HistoryCard(
                item: history[i],
                isDark: isDark,
                onTap: () {
                  provider.reuseHistoryResult(history[i]);
                  Navigator.pop(context);
                },
              ),
            ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử tính toán',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, CalculatorProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử không?'),
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

class _HistoryCard extends StatelessWidget {
  final CalculationHistory item;
  final bool isDark;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.expression,
              style: TextStyle(
                fontSize: kHistoryFontSize * 0.85,
                color: Colors.grey.shade500,
                fontFamily: kFont,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '= ${item.result}',
              style: TextStyle(
                fontSize: kHistoryFontSize,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                fontFamily: kFont,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.mode,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
                Text(
                  _formatTime(item.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
