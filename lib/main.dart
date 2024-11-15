import 'package:derejacom/HomeAppScreen.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'signin_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dereja.com App',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [MyNavigatorObserver()],
      routes: {
        '/': (context) => SplashScreen(),
      },
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  set onPopNext(Future<void> Function() onPopNext) {}

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name == '/home') {
      print('Returning to HomeScreen. Refresh required.');
    }
  }
}
