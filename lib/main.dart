import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  await dotenv.load(fileName: ".env");
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? exchangeRates;
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double amount = 0.0;
  double convertedAmount = 0.0;
  List<String> currencyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    try {
      final data = await apiService.fetchExchangeRates(fromCurrency);
      setState(() {
        exchangeRates = data;
        currencyList = exchangeRates!.keys.toList();
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching exchange rates: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _convertCurrency() {
    if (exchangeRates != null) {
      setState(() {
        convertedAmount = amount * (exchangeRates![toCurrency] ?? 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: fromCurrency.isNotEmpty ? fromCurrency : null,
                    onChanged: (value) {
                      setState(() {
                        fromCurrency = value!;
                        _fetchExchangeRates(); // Update rates when base currency changes
                      });
                    },
                    items: currencyList.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'From Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: toCurrency.isNotEmpty ? toCurrency : null,
                    onChanged: (value) {
                      setState(() {
                        toCurrency = value!;
                      });
                    },
                    items: currencyList.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'To Currency',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _convertCurrency,
                    child: const Text('Convert'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Converted Value: $convertedAmount',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }
}
