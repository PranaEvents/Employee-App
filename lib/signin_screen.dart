import 'package:derejacom/Api/api_base_url.dart';
import 'package:derejacom/HomeAppScreen.dart';
import 'package:derejacom/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Add this line
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false; // Loading state

  // Validate email
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    // else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    //   return 'Please enter a valid email';
    // }
    return null;
  }

  // Validate password
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  void _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      String email = _emailController.text;
      String password = _passwordController.text;

      // Call the API for authentication
      await authenticateUser(email, password);
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> authenticateUser(String email, String password) async {

    try {
      var url = Uri.parse(ApiConstants.getLoginUrl());
       print("object ${url}");
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'companyName': email,
            'password': password,
          }));

      if (response.statusCode == 200) {
        // Successfully signed in
        final data = jsonDecode(response.body);
        String token = data['data']; // Extract the token from the response

        // Save the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token); // Save token locally

        // Show success toast
        Fluttertoast.showToast(
          msg: "Login Successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Handle error
        print(response.body);
        final error = jsonDecode(response.body);
        
        Fluttertoast.showToast(
          msg: error['message'] ?? 'Login failed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print("object ${e}");
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/down5.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xffde9844), Color(0xffd22464)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Iconsax.user, color: Colors.grey),
                      labelText: 'Company Name',
                      hintText: 'dereja.com',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffde9844), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                    cursorColor: const Color(0xffde9844),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '*******',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Iconsax.password_check,
                          color: Colors.grey),
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffde9844), width: 2.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xffd22464),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xffde9844),
                        )
                      : fullWidthGradientButton(_signIn),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row with Image on the left and Text link centered
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image on the left
                Image.asset(
                  'assets/mcf.jpg', // Replace with your image path
                  height: 80,
                ),

                SizedBox(width: 8), // Spacing between image and text

                // Clickable text centered
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final url = Uri.parse("https://bit.ly/SystemElements");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Text(
                      'Powered by System Elements',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40.0),
      child: AppBar(
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/logo_kl0fke.png',
              width: 150,
              height: 150,
            ),
            Image.asset(
              'assets/dereja.png',
              width: 80,
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
