import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'crypto_detail_screen.dart';
import 'login_screen.dart';
import '../services/notification_service.dart';
import '../main.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key});

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  int _currentTab = 0;
  final Set<String> _portfolio = {};
  late Future<List<Crypto>> _cryptoFuture;

  @override
  void initState() {
    super.initState();
    _cryptoFuture = ApiService.fetchCryptos();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0E0F1A) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Crypto Tracker'),
        actions: [
          IconButton(
            icon: Icon(
              MyApp.of(context)?.isDark ?? true
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => MyApp.of(context)?.toggleTheme(),
          ),
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
        backgroundColor:
        isDark ? const Color(0xFF0E0F1A) : Colors.white,
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        selectedItemColor:
        isDark ? Colors.greenAccent : Colors.blue,
        unselectedItemColor: Colors.grey,
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
      future: _cryptoFuture,
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
    return FutureBuilder<List<Crypto>>(
      future: _cryptoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final coins =
        snapshot.data!.where((c) => _portfolio.contains(c.id)).toList();

        if (coins.isEmpty) {
          return const Center(child: Text('Портфель пуст'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: coins.length,
          itemBuilder: (_, i) => _cryptoCard(coins[i]),
        );
      },
    );
  }

  Widget _cryptoCard(Crypto crypto) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(color: Colors.white10)
              : null,
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto.symbol.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  crypto.name,
                  style: TextStyle(
                    color:
                    isDark ? Colors.grey : Colors.grey[700],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${crypto.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                        isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '${crypto.change24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: crypto.change24h >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    inPortfolio
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: isDark ? Colors.white : Colors.black,
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
