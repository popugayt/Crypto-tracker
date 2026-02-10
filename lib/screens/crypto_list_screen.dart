import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'crypto_detail_screen.dart';
import 'login_screen.dart';
import '../services/notification_service.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key});

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  int _currentTab = 0;
  final Set<String> _portfolio = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _currentTab == 0 ? _buildAllCryptos() : _buildPortfolio(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() => _currentTab = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Портфель',
          ),
        ],
      ),
    );
  }

  Widget _buildAllCryptos() {
    return FutureBuilder<List<Crypto>>(
      future: ApiService.fetchCryptos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final cryptos = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cryptos.length,
          itemBuilder: (_, i) => _cryptoCard(cryptos[i]),
        );
      },
    );
  }

  Widget _buildPortfolio() {
    if (_portfolio.isEmpty) {
      return const Center(child: Text('Портфель пуст'));
    }
    return FutureBuilder<List<Crypto>>(
      future: ApiService.fetchCryptos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final coins =
        snapshot.data!.where((c) => _portfolio.contains(c.id)).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: coins.length,
          itemBuilder: (_, i) => _cryptoCard(coins[i]),
        );
      },
    );
  }

  Widget _cryptoCard(Crypto crypto) {
    final inPortfolio = _portfolio.contains(crypto.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CryptoDetailScreen(crypto: crypto),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Информация о криптовалюте
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto.symbol.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(crypto.name, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            // Цена, изменение и кнопка добавления
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${crypto.price.toStringAsFixed(2)}'),
                    Text(
                      '${crypto.change24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: crypto.change24h >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    inPortfolio ? Icons.check_circle : Icons.add_circle_outline,
                  ),
                  onPressed: () async {
                    setState(() {
                      if (inPortfolio) {
                        _portfolio.remove(crypto.id);
                      } else {
                        _portfolio.add(crypto.id);
                      }
                    });

                    if (!inPortfolio) {
                      await NotificationService.showNotification(
                        title: 'Портфель обновлён',
                        body:
                        '${crypto.name} успешно добавлена в ваш портфель',
                      );
                      print('Уведомление отправлено'); // для отладки
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
