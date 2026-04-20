import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu lịch sử từ Provider
    final provider = context.watch<CalculatorProvider>();
    // Đảo ngược danh sách để phép tính mới nhất hiện lên trên cùng
    final history = provider.history.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF2D3142), // Màu nền primary
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Lịch sử', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Nút back màu trắng
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Xóa lịch sử',
            onPressed: () {
              // Gọi hàm xóa lịch sử
              context.read<CalculatorProvider>().clearHistory();
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'Chưa có lịch sử tính toán',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      history[index].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 28),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
