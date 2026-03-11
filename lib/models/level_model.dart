class Level {
  final int id;
  final String title;
  final String description;
  final LevelStatus status;
  final int xpReward;
  final int starsEarned;
  final String? icon;

  Level({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.xpReward,
    this.starsEarned = 0,
    this.icon,
  });
}

enum LevelStatus {
  locked,
  current,
  completed,
}

// Sample data for the levels
class LevelData {
  static List<Level> getLevels() {
    return [
      Level(
        id: 1,
        title: 'Profile Setup',
        description: 'Complete your profile to begin your journey',
        status: LevelStatus.completed,
        xpReward: 50,
        starsEarned: 3,
        icon: '👤',
      ),
      Level(
        id: 2,
        title: 'First Breath',
        description: 'Learn the basics of mindful breathing',
        status: LevelStatus.completed,
        xpReward: 50,
        starsEarned: 3,
        icon: '🌬️',
      ),
      Level(
        id: 3,
        title: '2-Min Breathing',
        description: 'Practice 2 minutes of conscious breathing',
        status: LevelStatus.completed,
        xpReward: 75,
        starsEarned: 3,
        icon: '🫁',
      ),
      Level(
        id: 4,
        title: 'Body Scan',
        description: 'Learn to scan your body for tension',
        status: LevelStatus.completed,
        xpReward: 100,
        starsEarned: 3,
        icon: '🧘',
      ),
      Level(
        id: 5,
        title: '5-Min Meditation',
        description: 'Guided meditation for beginners',
        status: LevelStatus.completed,
        xpReward: 100,
        starsEarned: 3,
        icon: '🧠',
      ),
      Level(
        id: 6,
        title: 'Stress Relief',
        description: 'Breathing techniques for stress management',
        status: LevelStatus.completed,
        xpReward: 125,
        starsEarned: 3,
        icon: '😌',
      ),
      Level(
        id: 7,
        title: 'Morning Routine',
        description: 'Start your day with mindfulness',
        status: LevelStatus.completed,
        xpReward: 125,
        starsEarned: 3,
        icon: '🌅',
      ),
      Level(
        id: 8,
        title: 'Evening Wind Down',
        description: 'Prepare for restful sleep',
        status: LevelStatus.completed,
        xpReward: 150,
        starsEarned: 3,
        icon: '🌙',
      ),
      Level(
        id: 9,
        title: 'Focus Power',
        description: 'Enhance concentration and clarity',
        status: LevelStatus.completed,
        xpReward: 150,
        starsEarned: 3,
        icon: '🎯',
      ),
      Level(
        id: 10,
        title: 'Anxiety Relief',
        description: 'Calm your mind during anxious moments',
        status: LevelStatus.completed,
        xpReward: 175,
        starsEarned: 3,
        icon: '💚',
      ),
      Level(
        id: 11,
        title: 'Deep Relaxation',
        description: 'Master advanced relaxation techniques',
        status: LevelStatus.completed,
        xpReward: 175,
        starsEarned: 3,
        icon: '🌊',
      ),
      Level(
        id: 12,
        title: 'Mindful Breath',
        description: 'Advanced breathing control exercises',
        status: LevelStatus.current,
        xpReward: 200,
        starsEarned: 0,
        icon: '✨',
      ),
      Level(
        id: 13,
        title: 'Energy Boost',
        description: 'Revitalize your body and mind',
        status: LevelStatus.locked,
        xpReward: 200,
        starsEarned: 0,
        icon: '⚡',
      ),
      Level(
        id: 14,
        title: 'Gratitude Practice',
        description: 'Cultivate daily gratitude habits',
        status: LevelStatus.locked,
        xpReward: 225,
        starsEarned: 0,
        icon: '🙏',
      ),
      Level(
        id: 15,
        title: 'Zen Master',
        description: 'Reach the ultimate state of mindfulness',
        status: LevelStatus.locked,
        xpReward: 250,
        starsEarned: 0,
        icon: '🏆',
      ),
    ];
  }
}
