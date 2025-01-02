import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = dotenv.env['APIKEY']!;
  final String baseUrl = dotenv.env['BASEURL']!;

  Future<Map<String, dynamic>> fetchExchangeRates(String baseCurrency) async {
    final response =
        await http.get(Uri.parse('$baseUrl/$apiKey/latest/$baseCurrency'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] == 'success') {
        return data['conversion_rates'];
      } else {
        throw Exception(
            'Failed to fetch exchange rates: ${data['error-type']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }
}
