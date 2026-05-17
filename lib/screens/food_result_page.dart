import 'dart:io';
import 'package:flutter/material.dart';
import '../services/food_service.dart';

class FoodItemResult {
  final String imagePath;
  final Map<String, dynamic> resultData;
  final double quantity;

  const FoodItemResult({
    required this.imagePath,
    required this.resultData,
    required this.quantity,
  });
}

class FoodResultPage extends StatefulWidget {
  final String? imagePath;
  final double? quantity;
  final Map<String, dynamic>? resultData;
  final List<FoodItemResult>? items;
  final int levelId;

  const FoodResultPage({
    super.key,
    this.imagePath,
    this.resultData,
    this.quantity,
    this.items,
    required this.levelId,
  });

  @override
  State<FoodResultPage> createState() => _FoodResultPageState();
}

class _FoodResultPageState extends State<FoodResultPage> {
  bool isSaving = false;
  bool isSaved = false;
  late int dietScore;
  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;
  double totalFiber = 0;

  @override
  void initState() {
    super.initState();
    if (widget.items != null && widget.items!.isNotEmpty) {
      _computeTotals();
    } else if (widget.resultData != null && widget.quantity != null) {
      dietScore = FoodService.calculateDietScore(widget.resultData!, widget.quantity!);
      _computeTotalsForSingle();
    } else {
      dietScore = 50;
    }
  }

  void _computeTotalsForSingle() {
    final data = widget.resultData!;
    final factor = widget.quantity! / 100;
    totalCalories = (data["calories"] ?? 0) * factor;
    totalProtein = (data["protein"] ?? 0) * factor;
    totalCarbs = (data["carbs"] ?? 0) * factor;
    totalFat = (data["fat"] ?? 0) * factor;
    totalFiber = (data["fiber"] ?? 0) * factor;
  }

  void _computeTotals() {
    double scoreSum = 0;
    double weightSum = 0;
    for (final item in widget.items!) {
      final data = item.resultData;
      final factor = item.quantity / 100;
      totalCalories += (data["calories"] ?? 0) * factor;
      totalProtein += (data["protein"] ?? 0) * factor;
      totalCarbs += (data["carbs"] ?? 0) * factor;
      totalFat += (data["fat"] ?? 0) * factor;
      totalFiber += (data["fiber"] ?? 0) * factor;

      final score = FoodService.calculateDietScore(data, item.quantity);
      scoreSum += score * item.quantity;
      weightSum += item.quantity;
    }

    if (weightSum > 0) {
      dietScore = (scoreSum / weightSum).round();
    } else {
      dietScore = 50;
    }
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
    final isMulti = widget.items != null && widget.items!.isNotEmpty;
    final data = widget.resultData;

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
            (widget.imagePath != null && widget.imagePath!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.file(
                      File(widget.imagePath!),
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
                          isMulti
                              ? "MEAL SUMMARY"
                              : data!["food"].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMulti
                              ? "${widget.items!.length} items"
                              : "${widget.quantity!.toStringAsFixed(0)} g",
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
                          "${totalCalories.toStringAsFixed(0)}",
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
                  _nutritionCard("Protein", totalProtein, Colors.green),
                  _nutritionCard("Carbs", totalCarbs, Colors.lightGreen),
                  _nutritionCard("Fat", totalFat, Colors.teal),
                  _nutritionCard("Fiber", totalFiber, Colors.lime),
                ],
              ),
            ),
            if (isMulti) const SizedBox(height: 12),
            if (isMulti)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: widget.items!
                      .map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(item.imagePath),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.resultData["food"].toString().toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item.quantity.toStringAsFixed(0)} g",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${((item.resultData["calories"] ?? 0) * (item.quantity / 100)).toStringAsFixed(0)} kcal",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
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