import 'package:shared_preferences/shared_preferences.dart';

class LevelService {

  Future<void> addXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();

    int currentXP = prefs.getInt("xp") ?? 0;
    int level = prefs.getInt("level") ?? 1;

    currentXP += xp;

    if (currentXP >= 100 && level == 1) {
      level = 2; // level 1 completed
    }

    await prefs.setInt("xp", currentXP);
    await prefs.setInt("level", level);
  }

  Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("xp") ?? 0;
  }

  Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("level") ?? 1;
  }
}