import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto.dart';

class ApiService {
  static const _url =
      'https://api.coingecko.com/api/v3/coins/markets'
      '?vs_currency=usd&order=market_cap_desc&per_page=10&page=1';

  static Future<List<Crypto>> fetchCryptos() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Crypto.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load crypto');
    }
  }
}
