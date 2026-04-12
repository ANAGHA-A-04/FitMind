import 'package:flutter/material.dart';
import '../services/wellness_service.dart';
import '../services/step_service.dart';
import '../services/health_service.dart';

class LevelDetailsPage extends StatefulWidget {
  final int levelId;
  const LevelDetailsPage({super.key, required this.levelId});

  @override
  State<LevelDetailsPage> createState() => _LevelDetailsPageState();
}

class _LevelDetailsPageState extends State<LevelDetailsPage>
    with SingleTickerProviderStateMixin {
  // State
  bool hasCheckedIn = false;
  bool isAnalyzing = false;

  // Check-in inputs
  String selectedMood = "";
  double sleepHours = 7.5;
  double stressLevel = 5;

  // Pedometer
  int steps = 0;
  final HealthService healthService = HealthService();

  // AI Output
  String currentWellnessState = "Unknown";
  String currentLifestyleCluster = "";

  // Animation controller for result reveal
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _loadSteps(); // 👈 IMPORTANT
  }
  Future<void> _loadSteps() async {
    int todaySteps = await healthService.getTodaySteps();

    print("UI received steps: $todaySteps"); // debug

    setState(() {
      steps = todaySteps;
    });
  }
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitCheckIn() async {
    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your mood first"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isAnalyzing = true);

    // Call both AI models in parallel
    final results = await Future.wait([
      WellnessService.getWellnessPrediction(
        steps,
        sleepHours,
        stressLevel,
        selectedMood,
      ),
      WellnessService.getLifestyleCluster(
        steps,
        sleepHours,
        stressLevel,
        5.0, // mood as numeric: mapped from string
        350,  // default calories (pedometer doesn't track calories yet)
      ),
    ]);

    if (!mounted) return;

    setState(() {
      currentWellnessState   = results[0];
      currentLifestyleCluster = results[1];
      isAnalyzing = false;
      hasCheckedIn = true;
    });

    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF062A1E),
      appBar: AppBar(
        title: Text("Level ${widget.levelId}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),

                  // Conditional: Check-in form OR AI Result
                  if (!hasCheckedIn)
                    _buildCheckInForm()
                  else
                    _buildWellnessResult(),
                ],
              ),
            ),

            // Loading overlay while AI analyzes
            if (isAnalyzing)
              Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D2B1F),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: const [
                            CircularProgressIndicator(
                              color: Colors.greenAccent,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "AI Analyzing Your Wellness...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Processing mood, sleep & activity data",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER WITH XP ───
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${widget.levelId}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "LEVEL ${widget.levelId}",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 120,
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: hasCheckedIn ? 1.0 : 0.0,
                        backgroundColor: Colors.black26,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: const [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 28,
              ),
              SizedBox(width: 5),
              Text(
                "🔥",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CHECK-IN FORM ───
  Widget _buildCheckInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Daily AI Check-in",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your responses power the AI wellness analysis.",
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),

        const SizedBox(height: 30),

        // ── MOOD SELECTION ──
        const Text(
          "How are you feeling today?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _moodButton("Happy", "😊"),
            _moodButton("Neutral", "😐"),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _moodButton("Sad", "😔"),
          ],
        ),

        const SizedBox(height: 30),

        // ── SLEEP SLIDER ──
        const Text(
          "Hours of Sleep",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.indigoAccent,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.indigoAccent,
            overlayColor: Colors.indigoAccent.withOpacity(0.2),
          ),
          child: Slider(
            value: sleepHours,
            min: 0,
            max: 10,
            divisions: 24,
            label: "${sleepHours.toStringAsFixed(1)} h",
            onChanged: (val) => setState(() => sleepHours = val),
          ),
        ),
        Text(
          "${sleepHours.toStringAsFixed(1)} hrs",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 25),

        // ── STRESS SLIDER ──
        const Text(
          "Stress Level",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.redAccent,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.redAccent,
            overlayColor: Colors.redAccent.withOpacity(0.2),
          ),
          child: Slider(
            value: stressLevel,
            min: 0,
            max: 10,
            divisions: 10,
            label: "${stressLevel.toInt()}/10",
            onChanged: (val) => setState(() => stressLevel = val),
          ),
        ),
        Text(
          "Stress: ${stressLevel.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 25),

        // ── PEDOMETER STEPS ──
        const Text(
          "Steps Today",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_walk,
                  color: Colors.greenAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$steps",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "steps counted by pedometer",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ── SUBMIT BUTTON ──
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _submitCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: const Color(0xFF062A1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Run AI Analysis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ─── MOOD BUTTON ───
  Widget _moodButton(String mood, String emoji) {
    bool isSelected = selectedMood == mood;
    return GestureDetector(
      onTap: () => setState(() => selectedMood = mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.42,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withOpacity(0.25)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Colors.greenAccent
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              mood,
              style: TextStyle(
                color: isSelected ? Colors.greenAccent : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AI WELLNESS RESULT ───
  Widget _buildWellnessResult() {
    // Dynamic color based on wellness state
    Color stateColor = Colors.greenAccent;
    IconData stateIcon = Icons.favorite;
    String stateMessage = "You're in great shape! Keep it up.";

    String stateLower = currentWellnessState.toLowerCase();

    if (stateLower.contains("stress")) {
      stateColor = Colors.redAccent;
      stateIcon = Icons.warning_amber_rounded;
      stateMessage =
          "High stress detected. Focus on relaxation and deep breathing today.";
    } else if (stateLower.contains("balanced")) {
      stateColor = Colors.amber;
      stateIcon = Icons.balance;
      stateMessage =
          "You're in a balanced state. Maintain your routine and stay mindful.";
    } else if (stateLower.contains("healthy")) {
      stateColor = Colors.greenAccent;
      stateIcon = Icons.favorite;
      stateMessage =
          "Excellent wellness! Your habits are paying off — keep going!";
    }

    return FadeTransition(
      opacity: _fadeIn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── AI STATE BANNER ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  stateColor.withOpacity(0.2),
                  stateColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stateColor.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(stateIcon, color: stateColor, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  "AI Wellness State",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentWellnessState,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  stateMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── SUBMITTED DATA SUMMARY ──
          const Text(
            "Your Check-in Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          _buildSummaryTile(
            icon: Icons.sentiment_satisfied_alt,
            label: "Mood",
            value: selectedMood,
            color: Colors.amber,
          ),
          _buildSummaryTile(
            icon: Icons.bedtime,
            label: "Sleep",
            value: "${sleepHours.toStringAsFixed(1)} hours",
            color: Colors.indigoAccent,
          ),
          _buildSummaryTile(
            icon: Icons.psychology,
            label: "Stress",
            value: "${stressLevel.toStringAsFixed(1)} / 10",
            color: Colors.redAccent,
          ),
          _buildSummaryTile(
            icon: Icons.directions_walk,
            label: "Steps",
            value: "$steps steps",
            color: Colors.greenAccent,
          ),

          const SizedBox(height: 24),

          // ── LIFESTYLE CLUSTER CARD ──
          if (currentLifestyleCluster.isNotEmpty)
            _buildClusterCard(),

          const SizedBox(height: 30),

          // ── DONE BUTTON ──
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Check-in saved! Great work today.'),
                  backgroundColor: Color(0xFF1E8A5E),
                ),
              );
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.greenAccent, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Complete Level Check-in",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── LIFESTYLE CLUSTER CARD ───
  Widget _buildClusterCard() {
    Color clusterColor;
    IconData clusterIcon;
    String clusterDesc;

    switch (currentLifestyleCluster) {
      case 'High-Energy Achiever':
        clusterColor = Colors.greenAccent;
        clusterIcon  = Icons.bolt;
        clusterDesc  = "You're highly active with great sleep and low stress. Keep up the momentum!";
        break;
      case 'Stressed Overworker':
        clusterColor = Colors.redAccent;
        clusterIcon  = Icons.warning_amber_rounded;
        clusterDesc  = "Your stress is elevated and sleep is low. Try to slow down and recharge.";
        break;
      case 'Sedentary/Relaxed':
        clusterColor = Colors.amberAccent;
        clusterIcon  = Icons.weekend;
        clusterDesc  = "You're calm but not very active. A short daily walk can boost your energy!";
        break;
      default:
        clusterColor = Colors.blueAccent;
        clusterIcon  = Icons.person;
        clusterDesc  = "Your lifestyle profile has been analyzed.";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            clusterColor.withOpacity(0.18),
            clusterColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: clusterColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: clusterColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(clusterIcon, color: clusterColor, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lifestyle Cluster",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  currentLifestyleCluster,
                  style: TextStyle(
                    color: clusterColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clusterDesc,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SUMMARY TILE ───
  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF132520),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
