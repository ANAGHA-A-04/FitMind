import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalXP = 2450;
  int currentLevel = 12;
  int currentStreak = 7;
  int longestStreak = 15;
  
  // Weekly activity data (7 days)
  final List<int> weeklyActivity = [20, 35, 45, 30, 50, 40, 55];
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Mood tracking
  String currentMood = 'Great';
  final List<MoodEntry> moodHistory = [
    MoodEntry('😊', 'Great', DateTime.now().subtract(const Duration(days: 0))),
    MoodEntry('😌', 'Good', DateTime.now().subtract(const Duration(days: 1))),
    MoodEntry('😊', 'Great', DateTime.now().subtract(const Duration(days: 2))),
    MoodEntry('🙂', 'Okay', DateTime.now().subtract(const Duration(days: 3))),
    MoodEntry('😊', 'Great', DateTime.now().subtract(const Duration(days: 4))),
  ];

  // Hydration data
  int waterCount = 6;
  int waterGoal = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A3A2A),
              Color(0xFF051810),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildWeeklyActivityChart(),
                const SizedBox(height: 24),
                _buildMoodTracker(),
                const SizedBox(height: 24),
                _buildHydrationTracker(),
                const SizedBox(height: 24),
                _buildAchievements(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00FF94),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.dashboard,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Track your wellness journey',
              style: TextStyle(
                color: Color(0xFF00FF94),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.emoji_events,
          title: 'Total XP',
          value: totalXP.toString(),
          color: const Color(0xFF00FF94),
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          title: 'Current Level',
          value: currentLevel.toString(),
          color: const Color(0xFF00BFFF),
        ),
        _buildStatCard(
          icon: Icons.local_fire_department,
          title: 'Current Streak',
          value: '$currentStreak days',
          color: const Color(0xFFFF6B35),
        ),
        _buildStatCard(
          icon: Icons.star,
          title: 'Longest Streak',
          value: '$longestStreak days',
          color: const Color(0xFFFFD700),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart() {
    double maxValue = weeklyActivity.reduce(math.max).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF94).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart, color: Color(0xFF00FF94), size: 24),
              SizedBox(width: 8),
              Text(
                'Weekly Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                double height = (weeklyActivity[index] / maxValue) * 120;
                bool isToday = index == 6;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${weeklyActivity[index]}',
                      style: TextStyle(
                        color: isToday ? const Color(0xFF00FF94) : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isToday
                              ? [const Color(0xFF00FF94), const Color(0xFF00BFFF)]
                              : [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weekDays[index],
                      style: TextStyle(
                        color: isToday ? const Color(0xFF00FF94) : Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF94).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.mood, color: Color(0xFF00FF94), size: 24),
              SizedBox(width: 8),
              Text(
                'Mood Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moodHistory.take(5).map((mood) {
              return Column(
                children: [
                  Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodButton('😊', 'Great'),
              _buildMoodButton('😌', 'Good'),
              _buildMoodButton('🙂', 'Okay'),
              _buildMoodButton('😔', 'Low'),
              _buildMoodButton('😰', 'Anxious'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentMood = label;
          moodHistory.insert(0, MoodEntry(emoji, label, DateTime.now()));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood logged: $label'),
            backgroundColor: const Color(0xFF00FF94),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTracker() {
    double progress = waterCount / waterGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.water_drop, color: Color(0xFF00BFFF), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Hydration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '$waterCount / $waterGoal glasses',
                style: const TextStyle(
                  color: Color(0xFF00BFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff00bffff)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: List.generate(waterGoal, (index) {
              bool isFilled = index < waterCount;
              return Icon(
                Icons.water_drop,
                color: isFilled ? const Color(0xFF00BFFF) : Colors.white24,
                size: 28,
              );
            }),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              if (waterCount < waterGoal) {
                setState(() {
                  waterCount++;
                });
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Glass'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.military_tech, color: Color(0xFFFFD700), size: 24),
              SizedBox(width: 8),
              Text(
                'Recent Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAchievementItem(
            '🔥',
            '7 Day Streak',
            'Keep the momentum going!',
          ),
          const SizedBox(height: 12),
          _buildAchievementItem(
            '🌟',
            'Level 12 Unlocked',
            'You\'re making great progress!',
          ),
          const SizedBox(height: 12),
          _buildAchievementItem(
            '💧',
            'Hydration Hero',
            'Stayed hydrated for 5 days',
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
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

class MoodEntry {
  final String emoji;
  final String label;
  final DateTime timestamp;

  MoodEntry(this.emoji, this.label, this.timestamp);
}
