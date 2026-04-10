import 'package:flutter/material.dart';
import 'food_scan_sheet.dart';
import 'level_details_page.dart';

class LevelOptionPage extends StatelessWidget {
  final int level;

  const LevelOptionPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Level $level"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 40),

            const Text(
              "Choose Your Activity",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // 🧠 WELLNESS BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelDetailsPage(levelId: level),
                  ),
                );
              },
              child: const Text("🧠 Wellness Check"),
            ),

            const SizedBox(height: 20),

            // 🍔 DIET BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  builder: (_) => const FoodScanSheet(),
                );
              },
              child: const Text("🍔 Diet Analysis"),
            ),
          ],
        ),
      ),
    );
  }
}