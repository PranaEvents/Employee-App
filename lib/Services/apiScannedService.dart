import 'dart:async';
import 'dart:convert';
import 'package:derejacom/Services/scannedCount.dart';
import 'package:derejacom/widgets/api_service.dart';
import 'package:http/http.dart' as http;

class ApiScannedService {
  // The API endpoint URL
  final String _url =
      'https://derejavrs2.azurewebsites.net/api/Account/TotalEventData';

  // Stream to fetch event data periodically
  Stream<ScannedCountData> fetchEventData() async* {
    while (true) {
      try {
        var response = await http.get(Uri.parse(_url));
        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          yield ScannedCountData.fromJson(
              jsonResponse); // Yield parsed EventData
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
      await Future.delayed(Duration(seconds: 2)); // Delay before next fetch
      ApiService();
    }
    
  }


}
