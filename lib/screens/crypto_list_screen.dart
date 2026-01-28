import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../services/api_service.dart';
import 'crypto_detail_screen.dart';

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
      ),
      body: _currentTab == 0 ? _buildAllCryptos() : _buildPortfolio(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline), // портфель / дипломат
            label: 'Портфель',
          ),
        ],
      ),
    );
  }

  // ---------- ГЛАВНАЯ ----------
  Widget _buildAllCryptos() {
    return FutureBuilder<List<Crypto>>(
      future: ApiService.fetchCryptos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Ошибка загрузки'));
        }

        final cryptos = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cryptos.length,
          itemBuilder: (context, index) {
            return _cryptoCard(cryptos[index]);
          },
        );
      },
    );
  }

  // ---------- ПОРТФЕЛЬ ----------
  Widget _buildPortfolio() {
    if (_portfolio.isEmpty) {
      return const Center(
        child: Text(
          'Портфель пуст',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return FutureBuilder<List<Crypto>>(
      future: ApiService.fetchCryptos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final portfolioCoins = snapshot.data!
            .where((crypto) => _portfolio.contains(crypto.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: portfolioCoins.length,
          itemBuilder: (context, index) {
            return _cryptoCard(portfolioCoins[index]);
          },
        );
      },
    );
  }

  // ---------- КАРТОЧКА ----------
  Widget _cryptoCard(Crypto crypto) {
    final bool inPortfolio = _portfolio.contains(crypto.id);

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
          border: Border.all(color: Colors.grey.shade800),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Левая колонка
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto.symbol.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  crypto.name,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Правая колонка + кнопка
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${crypto.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${crypto.change24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: crypto.change24h >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    inPortfolio ? Icons.check_circle : Icons.add_circle_outline,
                    color: inPortfolio ? Colors.greenAccent : Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      inPortfolio
                          ? _portfolio.remove(crypto.id)
                          : _portfolio.add(crypto.id);
                    });
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
