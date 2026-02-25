import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1F3B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "FitMind Login",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon:
                  const Icon(Icons.email, color: Colors.white70),
                  labelText: "Email",
                  labelStyle:
                  const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon:
                  const Icon(Icons.lock, color: Colors.white70),
                  labelText: "Password",
                  labelStyle:
                  const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Login Logic Here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B5EFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}