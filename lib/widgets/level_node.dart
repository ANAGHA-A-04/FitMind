import 'package:flutter/material.dart';
import '../models/level_model.dart';

class LevelNode extends StatelessWidget {
  final Level level;
  final VoidCallback? onTap;
  final bool isOnRight;

  const LevelNode({
    Key? key,
    required this.level,
    this.onTap,
    this.isOnRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: level.status == LevelStatus.current ? onTap : null,
      child: Container(
        margin: EdgeInsets.only(
          left: isOnRight ? MediaQuery.of(context).size.width * 0.5 : 20,
          right: isOnRight ? 20 : MediaQuery.of(context).size.width * 0.5,
          bottom: 60,
        ),
        child: Column(
          children: [
            // Level number label for locked nodes
            if (level.status == LevelStatus.locked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level.id.toString(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (level.status == LevelStatus.locked) const SizedBox(height: 8),

            // Current label for current node
            if (level.status == LevelStatus.current)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            if (level.status == LevelStatus.current) const SizedBox(height: 8),

            // Main circular node
            Container(
              width: level.status == LevelStatus.current ? 120 : 90,
              height: level.status == LevelStatus.current ? 120 : 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _getGradient(),
                border: Border.all(
                  color: level.status == LevelStatus.current
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  width: level.status == LevelStatus.current ? 4 : 2,
                ),
                boxShadow: level.status == LevelStatus.current
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00FF94).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: _buildNodeContent(),
              ),
            ),

            // Title for current level
            if (level.status == LevelStatus.current) ...[
              const SizedBox(height: 12),
              Text(
                level.title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF00FF94),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (level.status) {
      case LevelStatus.completed:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00FF94),
            const Color(0xFF00CC75),
          ],
        );
      case LevelStatus.current:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00FF94),
            const Color(0xFF00FFB2),
          ],
        );
      case LevelStatus.locked:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        );
    }
  }

  Widget _buildNodeContent() {
    switch (level.status) {
      case LevelStatus.completed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return const Icon(
              Icons.star,
              color: Colors.white,
              size: 20,
            );
          }),
        );
      case LevelStatus.current:
        return Text(
          level.id.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        );
      case LevelStatus.locked:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              color: Colors.white38,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              level.id.toString(),
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
    }
  }
}
