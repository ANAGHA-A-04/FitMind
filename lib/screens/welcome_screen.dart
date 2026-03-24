import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1F3B),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          const SizedBox(height: 60),

          // Illustration Section
          Stack(
            alignment: Alignment.center,
            children: [

              Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(120),
                ),
              ),

              const Icon(
                Icons.directions_run,
                size: 120,
                color: Colors.white,
              ),

              Positioned(
                top: 10,
                left: 40,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite, color: Colors.red),
                ),
              ),

              Positioned(
                top: 20,
                right: 40,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.water_drop, color: Colors.blue),
                ),
              ),

              Positioned(
                bottom: 10,
                left: 80,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.access_time, color: Colors.orange),
                ),
              ),
            ],
          ),

          // App Name & Tagline
          Column(
            children: const [
              Text(
                "FitMind",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Calm Mind. Active Body.",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          // Start Button
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5EFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Start Tracking",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}