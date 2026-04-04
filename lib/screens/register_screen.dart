import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  DateTime? selectedDate;
  String selectedGoal = "lose weight";
  bool isPasswordHidden = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
                children: [

                // Name
                _buildTextField(nameController, "Full Name", Icons.person),
            const SizedBox(height: 15),

            // Email
            _buildTextField(
              emailController,
              "Email",
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            // Password
            TextFormField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                ),
                enabledBorder: _border(),
                focusedBorder: _border(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            // Weight
            _buildTextField(
              weightController,
              "Weight (kg)",
              Icons.monitor_weight,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 15),

            // Height
            _buildTextField(
              heightController,
              "Height (cm)",
              Icons.height,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 15),

            // Date of Birth
            ListTile(
              tileColor: Colors.white10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                selectedDate == null
                    ? "Select Date of Birth"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                style: const TextStyle(color: Colors.white),
              ),
              trailing:
              const Icon(Icons.calendar_today, color: Colors.white),
              onTap: _pickDate,
            ),

            const SizedBox(height: 20),

            // Fitness Goal
            DropdownButtonFormField<String>(
              initialValue: selectedGoal,
              dropdownColor: Colors.blue[800],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Fitness Goal",
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: _border(),
                focusedBorder: _border(),
              ),
              items: [
                "lose weight",
                "gain muscle",
                "maintain fitness"
              ]
                  .map((goal) => DropdownMenuItem(
                value: goal,
                child: Text(
                  goal,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGoal = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            // Register Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5EFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _registerUser,
                child: const Text(
                  "Register",
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Already have account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            ],
          ),
        ),
      ),
    ),
    );


  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: _border(),
        focusedBorder: _border(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white54),
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );


    if (picked != null && mounted) {
    setState(() {
    selectedDate = picked;
    });
    }


  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select Date of Birth")),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Format date to ISO 8601 string
        final dateString = selectedDate!.toIso8601String();

        // Call API
        final result = await AuthService.register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          weight: double.parse(weightController.text),
          height: double.parse(heightController.text),
          dateOfBirth: dateString,
          goal: selectedGoal,
        );

        // Close loading indicator
        if (mounted) Navigator.pop(context);

        if (result['success'] == true) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Registration Successful!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to login screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          }
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Registration failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Close loading indicator
        if (mounted) Navigator.pop(context);

        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
