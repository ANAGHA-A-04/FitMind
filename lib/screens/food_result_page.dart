import 'dart:io';
import 'package:flutter/material.dart';

class FoodResultPage extends StatelessWidget {
  final String imagePath;

  const FoodResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [

          Image.file(
            File(imagePath),
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 20),

          const Text(
            "Food Name",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),

          const SizedBox(height: 10),

          const Text(
            "Calories: 120 kcal",
            style: TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );
  }
}