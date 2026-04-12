import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
from nutrition import get_nutrition
import argparse
import json
import sys

MODEL_PATH = "models/20260315-111204/best_model.keras (1)"
CLASS_PATH = "models/20260315-111204/class_names.txt"

# Load model with error handling
try:
    model = tf.keras.models.load_model(MODEL_PATH)
except Exception as e:
    print(f"Error loading model: {e}", file=sys.stderr)
    sys.exit(1)

# Load class names
try:
    with open(CLASS_PATH) as f:
        class_names = [line.strip() for line in f]
except Exception as e:
    print(f"Error loading class names: {e}", file=sys.stderr)
    sys.exit(1)

def analyze_image(image_path, grams=100):
    """Analyze a single image and return nutrition info"""
    try:
        # Load and preprocess image
        img = image.load_img(image_path, target_size=(224, 224))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)

        # Make prediction
        pred = model.predict(img_array, verbose=0)
        predicted_class = class_names[np.argmax(pred)]
        confidence = float(np.max(pred))

        # Get nutrition info
        nutrition = get_nutrition(predicted_class, grams)

        if nutrition:
            result = {
                "food": predicted_class,
                "confidence": round(confidence, 2),
                "calories": round(nutrition["calories"], 2),
                "protein": round(nutrition["protein"], 2),
                "carbs": round(nutrition["carbs"], 2),
                "fat": round(nutrition["fat"], 2),
                "fiber": round(nutrition["fiber"], 2)
            }
            return result
        else:
            return {
                "food": predicted_class,
                "confidence": round(confidence, 2),
                "error": "Nutrition data not found for this food"
            }
    except Exception as e:
        return {"error": f"Analysis failed: {str(e)}"}

def main():
    parser = argparse.ArgumentParser(description='FitMind Food Analysis')
    parser.add_argument('--image', help='Path to image file for analysis')
    parser.add_argument('--grams', type=float, default=100, help='Quantity in grams (default: 100)')
    parser.add_argument('--json', action='store_true', help='Output results as JSON')

    args = parser.parse_args()

    # API mode - analyze single image
    if args.image:
        result = analyze_image(args.image, args.grams)
        if args.json:
            print(json.dumps(result))
        else:
            if 'error' in result:
                print(f"Error: {result['error']}", file=sys.stderr)
                sys.exit(1)
            else:
                print(f"Predicted: {result['food']} ({result['confidence']})")
                print(f"Calories: {result['calories']} kcal")
                print(f"Protein: {result['protein']} g")
                print(f"Carbs: {result['carbs']} g")
                print(f"Fat: {result['fat']} g")
                print(f"Fiber: {result['fiber']} g")
        return

    # Interactive mode (original functionality)
    total = {
        "calories": 0,
        "protein": 0,
        "carbs": 0,
        "fat": 0,
        "fiber": 0
    }

    print("\n FitMind Smart Nutrition System")
    print("Choose input method:")
    print("1 → Upload Image")
    print("2 → Enter Food Name")
    print("Type 'done' to finish\n")

    while True:
        choice = input("Enter choice (1/2/done): ").lower()

        if choice == "done":
            break

        try:
            # ================= IMAGE INPUT =================
            if choice == "1":
                img_path = input("Enter image path: ")
                result = analyze_image(img_path)

                if 'error' in result:
                    print(f"Error: {result['error']}")
                    continue

                print(f"\n Predicted: {result['food']} ({result['confidence']})")
                food_name = result['food']

            # ================= TEXT INPUT =================
            elif choice == "2":
                food_name = input("Enter food name: ")
                print(f"\n You entered: {food_name}")

            else:
                print(" Invalid choice")
                continue

            # Quantity
            grams = float(input("Enter quantity in grams: "))

            # Get nutrition
            nutrition = get_nutrition(food_name, grams)

            if nutrition:
                print("\n Added to total")

                total["calories"] += nutrition["calories"]
                total["protein"] += nutrition["protein"]
                total["carbs"] += nutrition["carbs"]
                total["fat"] += nutrition["fat"]
                total["fiber"] += nutrition["fiber"]

            else:
                print(" Food not found in dataset")

            print("\n--------------------------\n")

        except Exception as e:
            print(f" Error: {e}\n")

    # FINAL OUTPUT
    print("\n TOTAL NUTRITION INTAKE ")
    print(f"Calories: {total['calories']:.2f} kcal")
    print(f"Protein: {total['protein']:.2f} g")
    print(f"Carbs: {total['carbs']:.2f} g")
    print(f"Fat: {total['fat']:.2f} g")
    print(f"Fiber: {total['fiber']:.2f} g")

if __name__ == "__main__":
    main()