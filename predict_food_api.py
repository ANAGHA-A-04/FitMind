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
import traceback

# Candidate model paths (checked in order)
MODEL_CANDIDATES = [
    "app_model.h5",
    "models/20260315-111204/final_model.keras",
    "models/20260315-111204/best_model.keras",
    "models/20260313-003259/final_model.keras",
    "models/20260313-003259/best_model.keras",
    "cnn_model/models/20260315-111204/best_model.keras",
]

CLASS_PATH = "models/20260315-111204/class_names.txt"

# Robust model loading: try several strategies and report detailed errors
model = None
found_model = None
load_errors = {}
for p in MODEL_CANDIDATES:
    if not os.path.exists(p):
        continue
    last_exc = None
    try:
        model = tf.keras.models.load_model(p, compile=False)
        found_model = p
        break
    except Exception as e1:
        last_exc = e1
    try:
        import keras as _keras
        try:
            model = _keras.models.load_model(p, compile=False)
            found_model = p
            break
        except Exception as e2:
            last_exc = e2
    except Exception:
        pass

    load_errors[p] = str(last_exc)

if model is None:
    tried = [p for p in MODEL_CANDIDATES]
    print("\nError loading model: none of the candidate files could be loaded.", file=sys.stderr)
    print(f"Tried: {tried}", file=sys.stderr)
    print("Per-file errors:", file=sys.stderr)
    for p, err in load_errors.items():
        print(f" - {p}: {err}", file=sys.stderr)
    print("\nSuggestions:", file=sys.stderr)
    print(" - Ensure you have a compatible TensorFlow/Keras version for the saved model format.", file=sys.stderr)
    print(" - If the model is a .keras archive, try re-saving it as HDF5 (model.save('model.h5')) or as a SavedModel directory.", file=sys.stderr)
    print(" - You can convert or re-export the model using the training scripts in `cnn_model`.", file=sys.stderr)
    sys.exit(1)
else:
    try:
        model.compile(
            optimizer='adam',
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
    except Exception:
        pass
    print(f"Loaded model from: {found_model}")

# Load class names after model is successfully loaded
try:
    with open(CLASS_PATH, 'r', encoding='utf-8') as f:
        class_names = [line.strip() for line in f if line.strip()]
except Exception as e:
    print(f"Error loading class names from {CLASS_PATH}: {e}", file=sys.stderr)
    sys.exit(1)
else:
    print(f"Loaded model from: {found_model}")

def analyze_image(image_path, grams=100):
    """Analyze a single image and return nutrition info"""
    try:
        # Load and preprocess image
        img = image.load_img(image_path, target_size=(224, 224))
        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)

        # Make prediction
        pred = model.predict(img_array, verbose=0)
        print(f"[DEBUG] prediction shape={pred.shape}, values={pred.flatten()[:5]}")

        class_index = int(np.argmax(pred))
        if class_index >= len(class_names):
            raise ValueError(f"predicted class index {class_index} out of range for {len(class_names)} class names")

        predicted_class = class_names[class_index]
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
        traceback.print_exc()
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