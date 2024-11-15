import 'package:derejacom/HomeAppScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'signin_screen.dart';
// Main screen after login

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);

    return Scaffold(
      body: Container(
        // Linear gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffd22464), Color(0xffde9844)], // Customize your gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Image.asset(
              'assets/expowhite-removebg-preview.png',
              width: 220,
              height: 220,
            ),
             
            ],
          ),
        ),
      ),
    );
  }

  // Check the login status
  void _checkLoginStatus(BuildContext context) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('authToken');

    Timer(const Duration(seconds: 3), () {
      if (token != null) {
        // Token exists, navigate to the main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // No token, navigate to the sign-in screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    });
  }
}
