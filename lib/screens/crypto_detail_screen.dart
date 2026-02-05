import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/crypto.dart';

class CryptoDetailScreen extends StatelessWidget {
  final Crypto crypto;

  const CryptoDetailScreen({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    final isPositive = crypto.change24h >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      appBar: AppBar(
        title: Text(crypto.symbol.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(isPositive),
          const SizedBox(height: 24),
          _chartSection(isPositive),
          const SizedBox(height: 24),
          _statsSection(),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(bool isPositive) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            crypto.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${crypto.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Text(
                '${crypto.change24h.toStringAsFixed(2)}% за 24ч',
                style: TextStyle(
                  fontSize: 16,
                  color:
                  isPositive ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CHART =================
  Widget _chartSection(bool isPositive) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Динамика цены (30 дней)',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: crypto.price * 0.05,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: crypto.price * 0.85,
                maxY: crypto.price * 1.15,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateMockData(),
                    isCurved: true,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    gradient: LinearGradient(
                      colors: isPositive
                          ? [
                        Colors.greenAccent,
                        Colors.greenAccent.withOpacity(0.4),
                      ]
                          : [
                        Colors.redAccent,
                        Colors.redAccent.withOpacity(0.4),
                      ],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isPositive
                            ? [
                          Colors.greenAccent.withOpacity(0.25),
                          Colors.transparent,
                        ]
                            : [
                          Colors.redAccent.withOpacity(0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _statsSection() {
    final min = crypto.price * 0.9;
    final max = crypto.price * 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Статистика',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _statCard('Минимум (30д)', min),
            _statCard('Максимум (30д)', max),
            _statCard('Текущая цена', crypto.price),
            _statCard('Изменение 24ч', crypto.change24h, percent: true),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, double value, {bool percent = false}) {
    return _card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            percent
                ? '${value.toStringAsFixed(2)}%'
                : '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  // ================= MOCK DATA =================
  List<FlSpot> _generateMockData() {
    final random = Random();
    double value = crypto.price;
    final List<FlSpot> spots = [];

    for (int i = 0; i < 30; i++) {
      value += (random.nextDouble() - 0.5) * crypto.price * 0.04;
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }
}
