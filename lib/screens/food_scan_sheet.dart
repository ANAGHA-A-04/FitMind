import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'food_result_page.dart';

class FoodScanSheet extends StatelessWidget {
  const FoodScanSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "AI Food Scanner",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 📸 TAKE PHOTO
          ElevatedButton(
            onPressed: () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);

              if (image != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodResultPage(imagePath: image.path),
                  ),
                );
              }
            },
            child: const Text("📸 Take Photo"),
          ),

          const SizedBox(height: 10),

          const Text("OR"),

          const SizedBox(height: 10),

          // 🖼 UPLOAD
          ElevatedButton(
            onPressed: () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodResultPage(imagePath: image.path),
                  ),
                );
              }
            },
            child: const Text("🖼 Upload from Gallery"),
          ),
        ],
      ),
    );
  }
}