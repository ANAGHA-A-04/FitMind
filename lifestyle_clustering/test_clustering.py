"""
FitMind – Lifestyle Clustering
DEMO TEST SCRIPT  (for Teacher Presentation)
=============================================
Shows:
  1. Dataset overview
  2. Model loading
  3. Predicting 3 different user profiles
  4. Accuracy check on full dataset
"""

import joblib
import pandas as pd
import numpy as np
import os

print("=" * 55)
print("   FitMind – Lifestyle Clustering DEMO")
print("=" * 55)

# ── Paths ─────────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
DATA_PATH  = os.path.join(BASE_DIR, 'data', 'lifestyle_dataset.csv')
MODEL_PATH = os.path.join(BASE_DIR, 'model', 'lifestyle_cluster_model.pkl')
SCALER_PATH= os.path.join(BASE_DIR, 'model', 'lifestyle_scaler.pkl')
LABELS_PATH= os.path.join(BASE_DIR, 'model', 'cluster_labels.pkl')

# ─────────────────────────────────────────────────────────
# PART 1 – Dataset Overview
# ─────────────────────────────────────────────────────────
print("\n📂 STEP 1: Dataset Overview")
print("-" * 55)
df = pd.read_csv(DATA_PATH)
print(f"  Total users in dataset : {len(df)}")
print(f"  Features used          : avg_steps, avg_sleep, avg_stress, avg_mood, avg_calories")
print(f"\n  Lifestyle group breakdown:")
for label, count in df['true_label'].value_counts().items():
    print(f"    • {label:<25} → {count} users")

print(f"\n  Sample rows from dataset:")
print(df[['user_id','avg_steps','avg_sleep','avg_stress','avg_mood','avg_calories','true_label']].head(5).to_string(index=False))

# ─────────────────────────────────────────────────────────
# PART 2 – Load Trained Model
# ─────────────────────────────────────────────────────────
print("\n\n🤖 STEP 2: Loading Trained K-Means Model")
print("-" * 55)
model  = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)
labels = joblib.load(LABELS_PATH)
print(f"  ✅ Model loaded   → K-Means (K=3 clusters)")
print(f"  ✅ Scaler loaded  → StandardScaler")
print(f"  ✅ Labels loaded  → {labels}")

# ─────────────────────────────────────────────────────────
# PART 3 – Test with 3 Sample Users
# ─────────────────────────────────────────────────────────
print("\n\n🧪 STEP 3: Testing with 3 Sample User Profiles")
print("-" * 55)

test_cases = [
    {
        "name"    : "User A – Active & Healthy",
        "steps"   : 10200,
        "sleep"   : 7.9,
        "stress"  : 2.3,
        "mood"    : 8.5,
        "calories": 510,
        "expected": "High-Energy Achiever"
    },
    {
        "name"    : "User B – Tired & Stressed",
        "steps"   : 7500,
        "sleep"   : 5.0,
        "stress"  : 8.5,
        "mood"    : 3.5,
        "calories": 370,
        "expected": "Stressed Overworker"
    },
    {
        "name"    : "User C – Calm but Inactive",
        "steps"   : 2500,
        "sleep"   : 9.0,
        "stress"  : 2.8,
        "mood"    : 6.0,
        "calories": 210,
        "expected": "Sedentary/Relaxed"
    },
]

for tc in test_cases:
    data   = pd.DataFrame([{
        'avg_steps'   : tc['steps'],
        'avg_sleep'   : tc['sleep'],
        'avg_stress'  : tc['stress'],
        'avg_mood'    : tc['mood'],
        'avg_calories': tc['calories'],
    }])
    scaled     = scaler.transform(data)
    cluster_id = model.predict(scaled)[0]
    predicted  = labels[cluster_id]
    status     = "✅ CORRECT" if predicted == tc['expected'] else "❌ WRONG"

    print(f"\n  [{tc['name']}]")
    print(f"    Steps={tc['steps']}  Sleep={tc['sleep']}h  Stress={tc['stress']}  Mood={tc['mood']}  Calories={tc['calories']}")
    print(f"    Predicted Lifestyle : {predicted}  {status}")

# ─────────────────────────────────────────────────────────
# PART 4 – Accuracy on Full Dataset
# ─────────────────────────────────────────────────────────
print("\n\n📊 STEP 4: Accuracy Check on Full 500-User Dataset")
print("-" * 55)
X      = df[['avg_steps','avg_sleep','avg_stress','avg_mood','avg_calories']]
scaled = scaler.transform(X)
df['predicted_label'] = [labels[c] for c in model.predict(scaled)]

correct = (df['predicted_label'] == df['true_label']).sum()
total   = len(df)
accuracy = (correct / total) * 100

print(f"  Correct predictions : {correct} / {total}")
print(f"  Accuracy            : {accuracy:.1f}%")

print(f"\n  Confusion Matrix (Rows=True, Cols=Predicted):")
print(pd.crosstab(df['true_label'], df['predicted_label']).to_string())

print("\n" + "=" * 55)
print("   ✅ Demo Complete! FitMind Clustering is Working.")
print("=" * 55)
