"""
FitMind – Behavioural Clustering Module
Step 1: Generate Synthetic Lifestyle Dataset

Generates a realistic dataset of 500 users with behavioral wellness data.
Each user represents 30-day averages of their daily check-in logs.

Clusters generated:
  - High-Energy Achievers  (active, low stress, good sleep)
  - Stressed Overworkers   (moderate activity, high stress, poor sleep)
  - Sedentary/Relaxed      (low activity, low stress, high sleep)
"""

import numpy as np
import pandas as pd
import os

# Reproducibility
np.random.seed(42)

os.makedirs('data', exist_ok=True)

print("📦 Generating FitMind Behavioural Dataset...")

# ─────────────────────────────────────────────────────
# GROUP A: High-Energy Achievers  (150 users)
#   High steps, good sleep, low stress, high mood
# ─────────────────────────────────────────────────────
n_a = 150
group_a = pd.DataFrame({
    'avg_steps':    np.random.normal(10500, 1000, n_a).clip(8000, 15000),
    'avg_sleep':    np.random.normal(7.8,   0.5,  n_a).clip(6.0, 9.5),
    'avg_stress':   np.random.normal(2.5,   0.7,  n_a).clip(1.0, 4.5),
    'avg_mood':     np.random.normal(8.0,   0.6,  n_a).clip(6.0, 10.0),
    'avg_calories': np.random.normal(520,   60,   n_a).clip(350, 700),
})
group_a['true_label'] = 'High-Energy Achiever'

# ─────────────────────────────────────────────────────
# GROUP B: Stressed Overworkers  (150 users)
#   Moderate-high steps, poor sleep, high stress, low mood
# ─────────────────────────────────────────────────────
n_b = 150
group_b = pd.DataFrame({
    'avg_steps':    np.random.normal(7800,  1500, n_b).clip(4000, 12000),
    'avg_sleep':    np.random.normal(5.2,   0.8,  n_b).clip(3.5, 7.0),
    'avg_stress':   np.random.normal(8.0,   1.0,  n_b).clip(5.5, 10.0),
    'avg_mood':     np.random.normal(4.0,   1.0,  n_b).clip(1.0, 6.5),
    'avg_calories': np.random.normal(380,   70,   n_b).clip(200, 560),
})
group_b['true_label'] = 'Stressed Overworker'

# ─────────────────────────────────────────────────────
# GROUP C: Sedentary/Relaxed  (200 users)
#   Low steps, high sleep, low stress, moderate mood
# ─────────────────────────────────────────────────────
n_c = 200
group_c = pd.DataFrame({
    'avg_steps':    np.random.normal(2800,  600,  n_c).clip(500, 5000),
    'avg_sleep':    np.random.normal(8.8,   0.6,  n_c).clip(7.0, 11.0),
    'avg_stress':   np.random.normal(3.0,   0.8,  n_c).clip(1.0, 5.0),
    'avg_mood':     np.random.normal(6.0,   1.0,  n_c).clip(3.0, 8.5),
    'avg_calories': np.random.normal(220,   50,   n_c).clip(80, 380),
})
group_c['true_label'] = 'Sedentary/Relaxed'

# ─────────────────────────────────────────────────────
# Combine and add user IDs
# ─────────────────────────────────────────────────────
df = pd.concat([group_a, group_b, group_c], ignore_index=True)
df.insert(0, 'user_id', [f'USR_{str(i+1).zfill(4)}' for i in range(len(df))])

# Round for readability
df['avg_steps']    = df['avg_steps'].round(0).astype(int)
df['avg_sleep']    = df['avg_sleep'].round(2)
df['avg_stress']   = df['avg_stress'].round(1)
df['avg_mood']     = df['avg_mood'].round(1)
df['avg_calories'] = df['avg_calories'].round(0).astype(int)

# Shuffle rows so groups aren't sequential
df = df.sample(frac=1, random_state=42).reset_index(drop=True)

# Save dataset
output_path = 'data/lifestyle_dataset.csv'
df.to_csv(output_path, index=False)

print(f"✅ Dataset saved to '{output_path}'")
print(f"   Total records : {len(df)}")
print(f"   Features      : avg_steps, avg_sleep, avg_stress, avg_mood, avg_calories")
print(f"\n📊 Class distribution:")
print(df['true_label'].value_counts().to_string())
print(f"\n📈 Feature summary:")
print(df[['avg_steps','avg_sleep','avg_stress','avg_mood','avg_calories']].describe().round(2))
