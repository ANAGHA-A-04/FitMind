import 'dart:io';
import 'package:flutter/material.dart';
import '../services/food_service.dart';

class FoodResultPage extends StatefulWidget {
  final String imagePath;
  final double quantity;
  final Map<String, dynamic> resultData;
  final int levelId;

  const FoodResultPage({
    super.key,
    required this.imagePath,
    required this.resultData,
    required this.quantity,
    required this.levelId,
  });

  @override
  State<FoodResultPage> createState() => _FoodResultPageState();
}

class _FoodResultPageState extends State<FoodResultPage> {
  bool isSaving = false;
  bool isSaved = false;
  late int dietScore;

  @override
  void initState() {
    super.initState();
    dietScore = FoodService.calculateDietScore(widget.resultData, widget.quantity);
  }

  Future<void> _completeDietCheckin() async {
    setState(() => isSaving = true);

    await FoodService.saveDietScoreLocally(
      levelId: widget.levelId,
      dietScore: dietScore,
    );

    await FoodService.saveDietScoreToBackend(
      userId: 1,
      levelId: widget.levelId,
      dietScore: dietScore,
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
      isSaved = true;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.resultData;
    final factor = widget.quantity / 100;

    final calories = (data["calories"] ?? 0) * factor;
    final protein = (data["protein"] ?? 0) * factor;
    final carbs = (data["carbs"] ?? 0) * factor;
    final fat = (data["fat"] ?? 0) * factor;
    final fiber = (data["fiber"] ?? 0) * factor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Food Analysis",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.imagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data["food"].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${widget.quantity.toStringAsFixed(0)} g",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Calories",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${calories.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "kcal",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Diet Score: $dietScore / 100",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _nutritionCard("Protein", protein, Colors.green),
                  _nutritionCard("Carbs", carbs, Colors.lightGreen),
                  _nutritionCard("Fat", fat, Colors.teal),
                  _nutritionCard("Fiber", fiber, Colors.lime),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _completeDietCheckin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _nutritionCard(String label, double value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${value.toStringAsFixed(1)} g",
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}