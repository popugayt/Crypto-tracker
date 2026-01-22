import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/crypto.dart';

class CryptoDetailScreen extends StatelessWidget {
  final Crypto crypto;

  const CryptoDetailScreen({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      appBar: AppBar(
        title: Text(crypto.symbol.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard(),
            const SizedBox(height: 20),
            _chartCard(),
            const SizedBox(height: 20),
            _statsCard(),
          ],
        ),
      ),
    );
  }

  // 🔹 Карточка с основной информацией
  Widget _infoCard() => _glassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          crypto.name,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${crypto.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Изменение за 24ч: ${crypto.change24h.toStringAsFixed(2)}%',
          style: TextStyle(
            color: crypto.change24h >= 0
                ? Colors.greenAccent
                : Colors.redAccent,
            fontSize: 18,
          ),
        ),
      ],
    ),
  );

  // 📈 График
  Widget _chartCard() => _glassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "График изменения курса (30 дней)",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minY: crypto.price * 0.85,
              maxY: crypto.price * 1.15,
              lineBarsData: [
                LineChartBarData(
                  spots: _generateMockData(),
                  isCurved: true,
                  color: crypto.change24h >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: (crypto.change24h >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent)
                        .withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // 📊 Статистика
  Widget _statsCard() => _glassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Статистика",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          "Минимум (30д): \$${(crypto.price * 0.9).toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          "Максимум (30д): \$${(crypto.price * 1.1).toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          "Средний курс: \$${crypto.price.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  // ✨ Glassmorphism карточка
  Widget _glassCard({required Widget child}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(24),
    ),
    child: child,
  );

  // 📉 Генерация тестовых данных для графика
  List<FlSpot> _generateMockData() {
    final List<FlSpot> spots = [];
    final random = Random();
    double value = crypto.price;

    for (int i = 0; i < 30; i++) {
      value += (random.nextDouble() - 0.5) * crypto.price * 0.05;
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }
}
