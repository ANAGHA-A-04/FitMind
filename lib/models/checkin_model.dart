import '../models/checkin_model.dart';
class CheckInModel {
  final int steps;
  final double sleepHours;
  final double stressLevel;
  final String mood;
  final DateTime date;

  CheckInModel({
    required this.steps,
    required this.sleepHours,
    required this.stressLevel,
    required this.mood,
    required this.date,
  });

  // Convert object to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      "steps": steps,
      "sleepHours": sleepHours,
      "stressLevel": stressLevel,
      "mood": mood,
      "date": date.toIso8601String(),
    };
  }

  // Convert JSON to object (when receiving data from backend)
  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      steps: json['steps'] ?? 0,
      sleepHours: (json['sleepHours'] ?? 0).toDouble(),
      stressLevel: (json['stressLevel'] ?? 0).toDouble(),
      mood: json['mood'] ?? "",
      date: DateTime.parse(json['date']),
    );
  }
}