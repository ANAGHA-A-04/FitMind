import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
from nutrition import get_nutrition

MODEL_PATH = "models/20260315-111204/best_model.keras (1)"
CLASS_PATH = "models/20260315-111204/class_names.txt"

# Load model
model = tf.keras.models.load_model(MODEL_PATH)

# Load class names
with open(CLASS_PATH) as f:
    class_names = [line.strip() for line in f]

# Total nutrients
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

            img = image.load_img(img_path, target_size=(224,224))
            img_array = image.img_to_array(img)
            img_array = np.expand_dims(img_array, axis=0)

            pred = model.predict(img_array)
            predicted_class = class_names[np.argmax(pred)]
            confidence = np.max(pred)

            print(f"\n Predicted: {predicted_class} ({confidence:.2f})")

            food_name = predicted_class

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