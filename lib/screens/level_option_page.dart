import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_scan_sheet.dart';
import 'level_details_page.dart';
import '../services/level_service.dart';
import '../services/food_service.dart';
import '../services/adaptive_service.dart';
import '../services/auth_service.dart';
import 'daily_tasks_page.dart';

class LevelOptionPage extends StatefulWidget {
  final int level;

  const LevelOptionPage({super.key, required this.level});

  @override
  State<LevelOptionPage> createState() => _LevelOptionPageState();
}

class _LevelOptionPageState extends State<LevelOptionPage> {
  bool wellnessDone = false;
  bool dietDone = false;
  bool isLevelCompleted = false;

  int? wellnessScore;
  int? dietScore;

  bool isGeneratingTasks = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkIfLevelCompleted();
  }

  Future<void> _checkIfLevelCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completedLevels = prefs.getStringList('completedLevels') ?? [];
    
    if (completedLevels.contains('${widget.level}')) {
      if (mounted) {
        setState(() => isLevelCompleted = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LevelOptionPage(level: widget.level + 1),
              ),
            );
          }
        });
      }
    }
  }

  Future<String> _getCurrentUserId() async {
    print("\n🔍 === GETTING USER ID ===");
    
    // Try using AuthService getter
    final userIdFromService = await AuthService.getUserId();
    print("1️⃣ From AuthService.getUserId(): '$userIdFromService'");
    
    if (userIdFromService != null && userIdFromService.isNotEmpty) {
      print("✅ UserID found: '$userIdFromService'");
      return userIdFromService;
    }
    
    // Fallback to direct SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    print("2️⃣ From direct SharedPreferences: '$userId'");

    if (userId == null || userId.isEmpty) {
      print("❌ User ID not found in SharedPreferences!");
      throw Exception("User ID not found. Please login again.");
    }

    print("✅ UserID found: '$userId'");
    return userId;
  }

  Future<void> _loadData() async {
    final wDone = await LevelService.isWellnessDone(widget.level);
    final wScore = await LevelService.getWellnessScoreForLevel(widget.level);

    final dDone = await FoodService.isDietDone(widget.level);
    final dScore = await FoodService.getDietScoreForLevel(widget.level);

    if (!mounted) return;

    setState(() {
      wellnessDone = wDone;
      wellnessScore = wScore;

      dietDone = dDone;
      dietScore = dScore;
    });
  }

  Future<void> _openWellness() async {
    if (wellnessDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Wellness check-in already completed for this level"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelDetailsPage(levelId: widget.level),
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _openDiet() async {
    if (dietDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Diet check-in already completed for this level"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) => FoodScanPage(levelId: widget.level),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _generateAndShowTasks() async {
    if (wellnessScore == null || dietScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Complete wellness and diet check-in first.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isGeneratingTasks = true;
    });

    try {
      final userId = await _getCurrentUserId();

      print("USER ID = $userId");

      final data = await AdaptiveService.generateTasks(
        userId: userId,
        wellnessScore: wellnessScore!,
        dietScore: dietScore!,
      );

      print("TASK RESPONSE = $data");

      final List<String> tasksList =
          List<String>.from(data["tasks"] ?? []);

      final String goalFromResponse =
          data["goal"] ?? "maintain fitness";

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DailyTasksPage(
            tasks: tasksList,
            goal: goalFromResponse,
            wellnessScore: wellnessScore!,
            dietScore: dietScore!,
            userId: userId,
            currentLevel: widget.level,
          ),
        ),
      );
    } catch (e) {
      print("TASK GENERATION ERROR = $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Could not generate tasks.\n$e",
          ),
          action: SnackBarAction(
            label: "Retry",
            textColor: Colors.white,
            onPressed: _generateAndShowTasks,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingTasks = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLevelCompleted) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Level ${widget.level}"),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "🎉 Level Complete!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Unlocking Level ${widget.level + 1}...",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Level ${widget.level}"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Welcome User",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // WELLNESS CARD
            GestureDetector(
              onTap: wellnessDone ? null : _openWellness,
              child: Opacity(
                opacity: wellnessDone ? 0.6 : 1.0,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2A2A3E),
                        Color(0xFF1A1A2E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Wellness',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Mood & Health',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (wellnessScore != null) ...[
              const SizedBox(height: 12),
              Text(
                "Wellness Score: $wellnessScore / 100",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // DIET CARD
            GestureDetector(
              onTap: dietDone ? null : _openDiet,
              child: Opacity(
                opacity: dietDone ? 0.6 : 1.0,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2A2A3E),
                        Color(0xFF1A1A2E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Diet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Analysis',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (dietScore != null) ...[
              const SizedBox(height: 12),
              Text(
                "Diet Score: $dietScore / 100",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 25),

            // ADAPTIVE ENGINE CARD
            if (wellnessScore != null && dietScore != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E3A5F),
                      Color(0xFF16213E),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Adaptive AI Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Generate personalized wellness and diet tasks based on your daily performance.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.greenAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        icon: isGeneratingTasks
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                    Colors.black,
                                  ),
                                ),
                              )
                            : const Icon(Icons.task_alt),
                        label: Text(
                          isGeneratingTasks
                              ? "Generating..."
                              : "View Today's Tasks",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: isGeneratingTasks
                            ? null
                            : _generateAndShowTasks,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}