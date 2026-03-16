import 'package:flutter/material.dart';
import '../models/level_model.dart';
import '../widgets/level_node.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Level> levels = LevelData.getLevels();
  int currentXP = 650;
  int maxXP = 1000;
  int totalPoints = 2450;

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
          child: Column(
            children: [
              _buildHeader(),
              _buildMilestoneCard(),
              Expanded(
                child: _buildLevelPath(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.spa,
              color: Color(0xFF00FF94),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'FitMind',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Zen Master Path',
                style: TextStyle(
                  color: Color(0xFF00FF94),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFF00FF94),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  totalPoints.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Settings
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Color(0xFF00FF94),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard() {
    int currentLevel = levels.firstWhere((l) => l.status == LevelStatus.current).id;
    double progress = currentXP / maxXP;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00FF94).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Milestone: Level $currentLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currentXP/$maxXP XP',
                style: const TextStyle(
                  color: Color(0xFF00FF94),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF94)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPath() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(top: 20, bottom: 80),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final reversedIndex = levels.length - 1 - index;
        final level = levels[reversedIndex];
        final isOnRight = reversedIndex % 2 == 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Dotted connecting line
            if (reversedIndex < levels.length - 1)
              Positioned(
                left: 0,
                right: 0,
                top: -30,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 60),
                  painter: DottedLinePainter(
                    startRight: !isOnRight,
                    color: level.status == LevelStatus.completed
                        ? const Color(0xFF00FF94)
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            // Level node
            LevelNode(
              level: level,
              isOnRight: isOnRight,
              onTap: () {
                _navigateToMission(level);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToMission(Level level) {
    // TODO: Navigate to mission page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A3A2A),
        title: Text(
          level.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'XP Reward: ${level.xpReward}',
              style: const TextStyle(
                color: Color(0xFF00FF94),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Start Mission',
              style: TextStyle(color: Color(0xFF00FF94)),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final bool startRight;
  final Color color;

  DottedLinePainter({
    required this.startRight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = startRight ? size.width * 0.65 : size.width * 0.35;
    double endX = startRight ? size.width * 0.35 : size.width * 0.65;
    double startY = 0;
    double endY = size.height;

    double distance = (endY - startY);
    int dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      double startYPos = startY + (i * (dashWidth + dashSpace));
      double endYPos = startYPos + dashWidth;
      
      double startXPos = startX + ((endX - startX) * (startYPos / distance));
      double endXPos = startX + ((endX - startX) * (endYPos / distance));

      canvas.drawLine(
        Offset(startXPos, startYPos),
        Offset(endXPos, endYPos),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
