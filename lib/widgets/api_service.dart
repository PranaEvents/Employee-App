import 'dart:async';
import 'dart:convert';
import 'package:derejacom/Api/api_base_url.dart';
import 'package:derejacom/widgets/card_item.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final StreamController<List<CardItem>> _itemsController =
      StreamController.broadcast();
  Timer? _timer;

  // Expose the stream
  Stream<List<CardItem>> get itemsStream => _itemsController.stream;

  // Function to fetch and update items
  Future<void> fetchItems(int page, int pageSize, String employerId) async {
    print("PageSize: $pageSize + PageNumber: $page + employeeId: $employerId");

    final String url =
        '${ApiConstants.getRegisteredEmployeesUrl(employerId)}?PageSize=$pageSize&PageNumber=$page';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final paginationHeader = response.headers['pagination'];
      print(paginationHeader);
      if (paginationHeader != null) {
        final paginationData = json.decode(paginationHeader);
        final totalItems = paginationData['totalItems'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('totalItems', totalItems);

        print("Total items stored in local storage: $totalItems");
      }

      List<dynamic> jsonResponse = json.decode(response.body);
  
      List<CardItem> items = jsonResponse
          .map((item) => CardItem(
                firstName: item['firstName'],
                lastName: item['lastName'],
                gender: item['gender'],
                disability: item['disablity'],
                phoneNumber: item['phoneNumber'],
                email: item['email'],
                university: item['university'],
                department: item['department'],
                region: item['region'],
                city: item['city'],
                yearofGraduate: item['yearofGraduate'],
                cvUrl: item['cvUrl'],
              ))
          .toList();

      // Add items to the stream
      _itemsController.add(items);
    } else {
      throw Exception('Failed to load items');
    }
  }

  // Start a timer to fetch items periodically
  Future<void> startFetchingItems(
      int page, int pageSize, String employerId, Duration interval) async {
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(interval, (Timer timer) {
      fetchItems(page, pageSize, employerId);
    });
  }

  // Dispose the StreamController and Timer when they're no longer needed
  void dispose() {
    _timer?.cancel(); // Cancel the timer if it's running
    _itemsController.close();
  }
}
