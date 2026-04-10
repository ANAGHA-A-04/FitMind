import 'package:flutter/material.dart';
import 'level_option_page.dart';
import 'chat_page.dart';
import '../services/level_service.dart';


class WellnessJourneyMap extends StatefulWidget {
  const WellnessJourneyMap({super.key});

  @override
  State<WellnessJourneyMap> createState() => _WellnessJourneyMapState();
}

class _WellnessJourneyMapState extends State<WellnessJourneyMap> {
  bool isLoading = true;
  int activeLevel = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
  

    int level = await LevelService.getActiveLevel();
    if (mounted) {
      setState(() {
        activeLevel = level;
        isLoading = false;
      });
    }
  }

  Widget _buildDynamicNode(BuildContext context, int level, {required bool isRight}) {
    if (level == activeLevel) {
      return _buildLiveNode(context, level, isRight: isRight);
    } else if (level < activeLevel) {
      return _buildLevelNode(context, level, isLocked: false, isRight: isRight);
    } else {
      return _buildLevelNode(context, level, isLocked: true, isRight: isRight);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B15),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00FF94))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B15), // Deep rich green-black
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: const Color(0xFF00FF94),
        child: const Icon(Icons.support_agent, color: Color(0xFF0D1B15), size: 28),
      ),
      appBar: AppBar(
        title: const Text("Wellness Journey", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.amber),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        reverse: true, // Start from the bottom (Level 0)
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              _buildMilestoneTitle("Advanced Awareness"),
              _buildDynamicNode(context, 4, isRight: true),
              _buildPath(),
              _buildDynamicNode(context, 3, isRight: false),
              _buildPath(),
              _buildMilestoneTitle("Foundation"),
              _buildDynamicNode(context, 2, isRight: true),
              _buildPath(),
              _buildDynamicNode(context, 1, isRight: false),
              _buildPath(),
              // Level 0
              _buildDynamicNode(context, 0, isRight: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPath() {
    return Container(
      height: 60,
      width: 4,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMilestoneTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildLevelNode(BuildContext context, int level, {required bool isLocked, required bool isRight}) {
    return Align(
      alignment: isRight ? const Alignment(0.4, 0) : const Alignment(-0.4, 0),
      child: GestureDetector(
        onTap: () {
          if (!isLocked) {
           _openLevel(context, level);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete previous levels first!')));
          }
        },
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLocked ? Colors.white.withOpacity(0.1) : const Color(0xFF1E3A2F),
                border: Border.all(
                  color: isLocked ? Colors.transparent : Colors.greenAccent,
                  width: 3,
                ),
              ),
              child: Icon(
                isLocked ? Icons.lock : Icons.check, 
                color: isLocked ? Colors.white54 : Colors.greenAccent,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "LEVEL $level",
              style: TextStyle(
                color: isLocked ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLiveNode(BuildContext context, int level, {required bool isRight}) {
    return Align(
      alignment: isRight ? const Alignment(0.4, 0) : const Alignment(-0.4, 0),
      child: GestureDetector(
        onTap: () => _openLevel(context, level),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent),
              ),
              child: const Text("LIVE", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
            const SizedBox(height: 5),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.psychology, color: Color(0xFF0D1B15), size: 45),
            ),
            const SizedBox(height: 8),
            Text(
              "LEVEL $level",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openLevel(BuildContext context, int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelOptionPage(level: level),
      ),
    );
  }
}
