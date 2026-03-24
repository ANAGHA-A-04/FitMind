import 'package:flutter/material.dart';
import '../models/checkin_model.dart';
import 'home_screen.dart';
import '../services/health_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {

  String selectedMood = "";
  double sleepHours = 7.5;
  double stressLevel = 5;

  int steps = 0;
  bool isLoadingSteps = true; // ✅ important

  final HealthService healthService = HealthService();
  Future<void> testStepFetch() async {
    print("Testing step fetch...");
    HealthService testService = HealthService();
    int testSteps = await testService.getTodaySteps();
    print("Test steps result: $testSteps");
  }

  @override
  void initState() {
    super.initState();
    testStepFetch();
    loadSteps();
  }

  // ✅ GET TODAY STEPS
  Future<void> loadSteps() async {
    try {
      int todaySteps = await healthService.getTodaySteps();

      setState(() {
        steps = todaySteps;
        isLoadingSteps = false;
      });

      print("Today's Steps (Health): $steps");

    } catch (e) {
      print("Error fetching steps: $e");
      setState(() {
        isLoadingSteps = false;
      });
    }
  }

  // ✅ MOOD BUTTON
  Widget moodButton(String mood, String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = mood;
        });
      },
      child: Container(
        width: 140,
        height: 120,
        decoration: BoxDecoration(
          color: selectedMood == mood
              ? Colors.green
              : Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              mood,
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  // ✅ SUBMIT CHECK-IN
  void submitCheckIn() {
    print("BUTTON CLICKED, steps: $steps, loading: $isLoadingSteps");
    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your mood")),
      );
      return;
    }
    if (isLoadingSteps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Loading steps... please wait")),
      );
      return;
    }
    print("FINAL Steps Sent: $steps");

    CheckInModel checkIn = CheckInModel(
      mood: selectedMood,
      sleepHours: sleepHours,
      stressLevel: stressLevel,
      steps: steps,
       date: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Daily Check-in Saved"),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          mood: selectedMood,
          sleep: sleepHours,
          stress: stressLevel,
          steps: steps, // ✅ CORRECT VALUE PASSED
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF062A1E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Daily Check-in"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "How are you feeling today?",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                moodButton("Happy", "😊"),
                moodButton("Neutral", "😐"),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                moodButton("Sad", "😔"),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Hours of Sleep",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),

            Slider(
              min: 0,
              max: 12,
              value: sleepHours,
              onChanged: (value) {
                setState(() {
                  sleepHours = value;
                });
              },
            ),

            Text(
              "${sleepHours.toStringAsFixed(1)} hrs",
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 25),

            const Text(
              "Stress Level",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),

            Slider(
              min: 0,
              max: 10,
              value: stressLevel,
              onChanged: (value) {
                setState(() {
                  stressLevel = value;
                });
              },
            ),

            Text(
              "Stress: ${stressLevel.toStringAsFixed(1)}",
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 25),

            const Text(
              "Steps Today",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),

            const SizedBox(height: 10),

            isLoadingSteps
                ? const Text(
              "Fetching steps...",
              style: TextStyle(color: Colors.white),
            )
                : Text(
              "$steps steps",
              style: const TextStyle(
                fontSize: 26,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoadingSteps ? null : submitCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Submit Check-in"),
              ),
            )
          ],
        ),
      ),
    );
  }
}