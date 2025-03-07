import 'package:currency_converter_app/countries.dart';
import 'package:currency_converter_app/country_data.dart';
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
  CurrencyConverterScreenState createState() => CurrencyConverterScreenState();
}

class CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final ApiService apiService = ApiService();
  final Countries countries = Countries();
  Map<String, dynamic>? exchangeRates;
  List<Map<String, dynamic>> countryInfo = [];
  String fromCurrency = 'AED';
  String toCurrency = 'AED';
  double amount = 0.0;
  double amount2 = 0.0;
  double convertedAmount = 0.0;
  List<String> currencyList = [];
  bool isLoading = true;

  // TextEditingController to manage the TextField value
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrencyData();
  }

  Future<void> _fetchCurrencyData() async {
    try {
      final data = await apiService.fetchExchangeRates(fromCurrency);
      final countryData = await countries.getCountryData();

      setState(() {
        countryInfo = countryData;
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
        amount2 = amount;
        convertedAmount = amount * (exchangeRates![toCurrency] ?? 1.0);
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;

      if (exchangeRates != null && exchangeRates![toCurrency] != null) {
        // Update the amount based on the current exchange rate
        amount = amount * (exchangeRates![toCurrency] ?? 1.0);
        amountController.text =
            amount.toStringAsFixed(2); // Update the TextField
      }

      _fetchCurrencyData(); // Fetch new exchange rates
      _convertCurrency(); // Perform the conversion again
    });
  }

  void _showCurrencySelector(bool isFromCurrency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Makes the background transparent
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CurrencySelectionSheet(
          currencies: currencyList,
          onCurrencySelected: (String selectedCurrency) {
            setState(() {
              if (isFromCurrency) {
                fromCurrency = selectedCurrency;
                _fetchCurrencyData();
              } else {
                toCurrency = selectedCurrency;
              }
            });
            Navigator.pop(context);
          },
        );
      },
    );
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
                    controller: amountController, // Bind the controller
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
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showCurrencySelector(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "From  ",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  fromCurrency,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, size: 32),
                        onPressed: _swapCurrencies,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showCurrencySelector(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "TO  ",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  toCurrency,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _convertCurrency,
                    child: const Text('Convert'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$fromCurrency $amount2: $convertedAmount $toCurrency',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }
}

class CurrencySelectionSheet extends StatefulWidget {
  final List<String> currencies;
  final ValueChanged<String> onCurrencySelected;

  const CurrencySelectionSheet({
    super.key,
    required this.currencies,
    required this.onCurrencySelected,
  });

  @override
  CurrencySelectionSheetState createState() => CurrencySelectionSheetState();
}

class CurrencySelectionSheetState extends State<CurrencySelectionSheet> {
  late List<Map<String, dynamic>> filteredCurrencies;

  @override
  void initState() {
    super.initState();
    filteredCurrencies = widget.currencies
        .asMap()
        .entries
        .map((entry) => {
              "currency": entry.value,
              "index": entry.key,
            })
        .toList();
  }

  void _filterCurrencies(String query) {
    setState(() {
      filteredCurrencies = widget.currencies
          .asMap()
          .entries
          .where((entry) =>
              entry.value.toLowerCase().contains(query.toLowerCase()))
          .map((entry) => {
                "currency": entry.value,
                "index": entry.key,
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Currency',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterCurrencies,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filteredCurrencies.length,
                  itemBuilder: (context, index) {
                    // Get the original index from the filtered list
                    int originalIndex = filteredCurrencies[index]["index"];

                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Display flag using the original index
                          Image.network(
                            width: 20,
                            "https://flagcdn.com/w320/${countryData[originalIndex][0].toLowerCase()}.png",
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 20,
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Text(filteredCurrencies[index]["currency"]),
                        ],
                      ),
                      onTap: () {
                        widget.onCurrencySelected(
                            filteredCurrencies[index]["currency"]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
