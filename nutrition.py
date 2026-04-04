import pandas as pd
from rapidfuzz import process

df = pd.read_csv("nutrition_dataset_v2.csv")
food_list = df['food_name'].tolist()

def normalize_name(food_name):
    return food_name.lower().replace(" ", "_")

def suggest_food(user_input):
    user_input = normalize_name(user_input)

    matches = process.extract(user_input, food_list, limit=3)

    return matches

def get_nutrition(food_name, grams):

    normalized = normalize_name(food_name)

    # Exact match
    if normalized in food_list:
        final_food = normalized

    else:
        matches = suggest_food(food_name)

        if not matches:
            return None

        print("\n Food not found. Suggestions:")
        for i, (name, score, _) in enumerate(matches):
            print(f"{i+1}. {name}")

        choice = input("Choose option (1/2/3) or type 'no': ").lower()

        if choice in ["1", "2", "3"]:
            final_food = matches[int(choice)-1][0]
        else:
            print(" No valid selection")
            return None

    food = df[df['food_name'] == final_food]

    factor = grams / 100

    result = {
        "food": final_food,
        "calories": round(float(food.iloc[0]['calories_kcal']) * factor, 2),
        "protein": round(float(food.iloc[0]['protein_g']) * factor, 2),
        "carbs": round(float(food.iloc[0]['carbs_g']) * factor, 2),
        "fat": round(float(food.iloc[0]['fat_g']) * factor, 2),
        "fiber": round(float(food.iloc[0]['fiber_g']) * factor, 2)
    }

    return result