import 'package:flutter/material.dart';
import '../services/step_service.dart';
import '../widgets/mood_card.dart';
import '../widgets/step_progress.dart';

class HomeScreen extends StatefulWidget {

  final String mood;
  final double sleep;
  final double stress;
  final int steps;

  const HomeScreen({
    super.key,
    required this.mood,
    required this.sleep,
    required this.stress,
    required this.steps,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int steps = 0;
  int? initialSteps;
  final StepService stepService = StepService();

  @override
  void initState() {
    super.initState();

    stepService.startStepCounter((stepCount) {
      if (initialSteps == null) {
        initialSteps = stepCount;
      }
      setState(() {
        steps = stepCount -initialSteps!;
      });
    });
  }

  @override
  void dispose() {
    stepService.stopStepCounter();
    super.dispose();
  }





  // WELLNESS SCORE CALCULATION
  double calculateWellness() {

    double sleepScore = (widget.sleep / 8) * 40;
    double stressScore = (10 - widget.stress) * 3;
    double stepScore = (steps / 10000) * 30;

    double total = sleepScore + stressScore + stepScore;

    if (total > 100) {
      total = 100;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {

    double wellnessScore = calculateWellness();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "FitMind",
          style: TextStyle(fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 22,),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // STEP PROGRESS
            StepProgress(steps: steps),

            const SizedBox(height: 30),

            // WELLNESS + MOOD CARDS
            Row(
              children: [

                Expanded(
                  child: MoodCard(
                    emoji: "Wellness",
                    label: "${wellnessScore.toStringAsFixed(0)}/100",
                    onTap: () {},
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: MoodCard(
                    emoji: widget.mood,
                    label: "Today's Mood",
                    onTap: () {},
                  ),
                ),

              ],
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Weekly Activity",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF132520),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "Weekly Graph shows here",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}