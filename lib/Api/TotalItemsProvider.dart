import 'dart:async';
import 'package:derejacom/widgets/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotalItemsProvider {
  late Timer _timer;
  final Duration refreshInterval;
  final StreamController<int?> _controller = StreamController<int?>.broadcast();

  TotalItemsProvider({this.refreshInterval = const Duration(seconds: 2)}) {
    _startAutoRefresh();
  }

  Stream<int?> get totalItemsStream => _controller.stream;

  void _startAutoRefresh() {
    _timer = Timer.periodic(refreshInterval, (timer) async {
      int? totalItems = await _getTotalItemsFromLocalStorage();
      _controller.add(totalItems);
    });
    ApiService();
    print("object");
  }

  Future<int?> _getTotalItemsFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs
        .getInt('totalItems'); // Get 'totalItems' from SharedPreferences
  }

  void dispose() {
    _timer.cancel();
    _controller.close();
  }
}
