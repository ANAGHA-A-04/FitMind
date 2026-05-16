import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/task_service.dart';

import 'wellness_journey_map.dart';

class DailyTasksPage extends StatefulWidget {
  final List<String> tasks;
  final String goal;
  final int wellnessScore;
  final int dietScore;
  final String userId;
  final int currentLevel;

  const DailyTasksPage({
    super.key,
    required this.tasks,
    required this.goal,
    required this.wellnessScore,
    required this.dietScore,
    required this.userId,
    this.currentLevel = 1,
  });

  @override
  State<DailyTasksPage> createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage> {
  late List<bool> completed;
  late Map<int, double> sliderValues; // For quantifiable tasks
  bool isLoading = false;
  bool isLevelCompleted = false; // Check if already completed

  @override
  void initState() {
    super.initState();
    completed = List.generate(widget.tasks.length, (_) => false);
    sliderValues = {};
    // Initialize slider values to 0 for quantifiable tasks
    for (int i = 0; i < widget.tasks.length; i++) {
      if (isQuantifiableTask(i)) {
        sliderValues[i] = 0;
      }
    }
    _checkIfAlreadyCompleted();
  }

  Future<void> _checkIfAlreadyCompleted() async {
    // Check if this level's tasks were already completed
    final prefs = await SharedPreferences.getInstance();
    final completedLevels = prefs.getStringList('completedLevels') ?? [];
    
    if (completedLevels.contains('${widget.currentLevel}')) {
      setState(() => isLevelCompleted = true);
    }
  }

  // Detect if a task is quantifiable and return target value
  bool isQuantifiableTask(int index) {
    final task = widget.tasks[index].toLowerCase();
    // Check for keywords that indicate numeric/quantifiable tasks
    return (task.contains('steps') && _extractNumber(task) != null) ||
           (task.contains('minutes') && _extractNumber(task) != null) ||
           (task.contains('water') && _extractNumber(task) != null) ||
           (task.contains('pushups') && _extractNumber(task) != null) ||
           (task.contains('glasses') && _extractNumber(task) != null);
  }

  double? _extractNumber(String text) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(text);
    return match != null ? double.parse(match.group(1)!) : null;
  }

  double? getTaskTarget(int index) {
    final task = widget.tasks[index].toLowerCase();
    return _extractNumber(task);
  }

  String getTaskUnit(int index) {
    final task = widget.tasks[index].toLowerCase();
    if (task.contains('steps')) return ' steps';
    if (task.contains('water') || task.contains('glasses')) return ' glasses';
    if (task.contains('minutes')) return ' min';
    if (task.contains('pushups')) return ' pushups';
    return '';
  }

  double get completedCount {
    double count = 0;
    for (int i = 0; i < widget.tasks.length; i++) {
      if (isQuantifiableTask(i)) {
        count += (sliderValues[i] ?? 0) / (getTaskTarget(i) ?? 1);
      } else {
        if (completed[i]) count += 1;
      }
    }
    return count;
  }

  double get progress {
    if (widget.tasks.isEmpty) return 0;
    return completedCount / widget.tasks.length;
  }

  String get wellnessState {
    if (widget.wellnessScore < 40) {
      return "Stressed";
    } else if (widget.wellnessScore < 70) {
      return "Balanced";
    } else {
      return "Active";
    }
  }

  String get difficulty {
    if (widget.wellnessScore < 40) {
      return "Easy";
    } else if (widget.wellnessScore < 70) {
      return "Medium";
    } else {
      return "Hard";
    }
  }

  Future<void> _submitCompletion() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // Build task completion data
    final List<Map<String, dynamic>> taskData = [];
    for (int i = 0; i < widget.tasks.length; i++) {
      final isQuant = isQuantifiableTask(i);
      final target = getTaskTarget(i);
      
      taskData.add({
        'name': widget.tasks[i],
        'isQuantifiable': isQuant,
        'isCompleted': isQuant ? false : completed[i],
        'targetValue': target ?? 0,
        'actualValue': isQuant ? (sliderValues[i] ?? 0) : 0,
      });
    }

    // Call backend
    final response = await TaskService.completeLevel(
      userId: widget.userId,
      level: widget.currentLevel,
      tasks: taskData,
      wellnessScore: widget.wellnessScore,
      dietScore: widget.dietScore,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      final completion = response['completion'];
      final completionPercent = completion['completionPercentage'];
      final xpEarned = completion['xpEarned'];
      final userStats = response['userStats'];
      final nextLevel = userStats['currentLevel']; // Use backend's level

      // Mark this level as completed locally
      final prefs = await SharedPreferences.getInstance();
      final completedLevels = prefs.getStringList('completedLevels') ?? [];
      completedLevels.add('${widget.currentLevel}');
      await prefs.setStringList('completedLevels', completedLevels);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${completionPercent}% Complete! +$xpEarned XP\n🎉 Unlocking Level $nextLevel...',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to journey map
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        
        // Pop current and previous screens
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Go back to Journey Map
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const WellnessJourneyMap(),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${response['error'] ?? 'Unknown error'}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Today's Adaptive Tasks"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP SUMMARY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Wellness Summary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: infoTile(
                          "Goal",
                          widget.goal,
                        ),
                      ),
                      Expanded(
                        child: infoTile(
                          "State",
                          wellnessState,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: infoTile(
                          "Difficulty",
                          difficulty,
                        ),
                      ),
                      Expanded(
                        child: infoTile(
                          "Diet Score",
                          "${widget.dietScore}",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // COMPLETED STATUS (if already done)
            if (isLevelCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Level ${widget.currentLevel} Already Completed!',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (isLevelCompleted) const SizedBox(height: 20),

            // TASK TITLE
            const Text(
              "Today's Recommended Tasks",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // TASK LIST or placeholder
            if (widget.tasks.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No tasks for today. Complete a check-in to generate tasks.",
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: widget.tasks.length,
                  itemBuilder: (context, index) {
                    final isQuantifiable = isQuantifiableTask(index);
                    final target = getTaskTarget(index);
                    final unit = getTaskUnit(index);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Opacity(
                        opacity: isLevelCompleted ? 0.5 : 1.0,
                        child: isQuantifiable
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            widget.tasks[index],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: Icon(
                                            Icons.trending_up,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${sliderValues[index]?.toStringAsFixed(0) ?? 0}${unit}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          "Target: ${target?.toStringAsFixed(0)}${unit}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Slider(
                                      value: sliderValues[index] ?? 0,
                                      min: 0,
                                      max: target ?? 100,
                                      divisions: (target ?? 100).toInt(),
                                      onChanged: isLevelCompleted
                                          ? null
                                          : (value) {
                                              setState(() {
                                                sliderValues[index] = value;
                                              });
                                            },
                                    ),
                                  ],
                                ),
                              )
                            : CheckboxListTile(
                                value: completed[index],
                                onChanged: isLevelCompleted
                                    ? null
                                    : (value) {
                                        setState(() {
                                          completed[index] = value ?? false;
                                        });
                                      },
                                title: Text(
                                  widget.tasks[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: completed[index]
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.task_alt,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                activeColor: Colors.green,
                                controlAffinity: ListTileControlAffinity.trailing,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),

            // PROGRESS SECTION
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daily Progress",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${completedCount.toStringAsFixed(1)} / ${widget.tasks.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Reward",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "+${(completedCount * 10).toInt()} XP",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // COMPLETE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isLoading || isLevelCompleted) ? null : _submitCompletion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (isLoading || isLevelCompleted) ? Colors.grey : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLevelCompleted
                    ? const Text(
                        '✅ Level Completed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit Completion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}