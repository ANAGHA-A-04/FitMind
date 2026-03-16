import 'package:flutter/material.dart';

class MoodCard extends StatelessWidget {

  final String emoji;
  final String label;
  final VoidCallback onTap;

  MoodCard({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 40)),
          Text(label)
        ],
      ),
    );
  }
}