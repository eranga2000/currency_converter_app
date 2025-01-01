import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey =
      'YOUR_API_KEY'; // Replace with your ExchangeRate-API key
  final String baseUrl = 'https://v6.exchangerate-api.com/v6';

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
