class Crypto {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double change24h;

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change24h,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      price: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      change24h:
      (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
