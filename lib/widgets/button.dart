import 'package:flutter/material.dart';

ElevatedButton fullWidthGradientButton(VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0), // Remove padding to fit container
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    child: Ink(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffde9844), Color(0xffd22464)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 50), // Button height
        child: const Text(
          'Sign In',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    ),
  );
}
