import 'package:flutter/material.dart';

class StepProgress extends StatelessWidget {
  final int steps;
  final int goal;

  const StepProgress({
    super.key,
    required this.steps,
    this.goal = 10000,
  });

  @override
  Widget build(BuildContext context) {
    double progress = steps / goal;

    if (progress > 1) {
      progress = 1;
    }

    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [

            // Background Circle
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),

            // Step Text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.directions_walk,
                  color: Colors.green,
                  size: 30,
                ),

                const SizedBox(height: 8),

                Text(
                  "$steps",
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "of $goal steps",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}