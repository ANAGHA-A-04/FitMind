import 'package:flutter/material.dart';

class DailyTasksPage extends StatefulWidget {
  final List<String> tasks;
  final String goal;
  final int wellnessScore;
  final int dietScore;

  const DailyTasksPage({
    super.key,
    required this.tasks,
    required this.goal,
    required this.wellnessScore,
    required this.dietScore,
  });

  @override
  State<DailyTasksPage> createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage> {
  late List<bool> completed;

  @override
  void initState() {
    super.initState();
    completed = List.generate(widget.tasks.length, (_) => false);
  }

  int get completedCount {
    return completed.where((task) => task).length;
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
                      child: CheckboxListTile(
                        value: completed[index],
                        onChanged: (value) {
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
                        "${completedCount} / ${widget.tasks.length}",
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
                        "+${completedCount * 10} XP",
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