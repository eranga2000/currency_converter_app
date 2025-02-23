import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Countries {
  Future<List<Map<String, dynamic>>> getCountryData() async {
    try {
      // Load the JSON file from assets
      String jsonString = await rootBundle.loadString('assets/country_data.json');

      // Decode JSON string to List
      List<dynamic> fetchedList = jsonDecode(jsonString);

      // Ensure correct type conversion
      return List<Map<String, dynamic>>.from(fetchedList);
    } catch (e) {
      print("Error loading country data: $e");
      return [];
    }
  }
}
