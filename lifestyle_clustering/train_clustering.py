import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import joblib
import os

# 1. Create directory
os.makedirs('model', exist_ok=True)

print("Starting Behavioural Clustering Model Training...")

# 2. Load Dataset for FitMind Users
# Features: [avg_steps, avg_sleep, avg_stress, avg_mood, avg_calories]
df = pd.read_csv('data/lifestyle_dataset.csv')

# Drop the id and true_label columns for training
X = df[['avg_steps', 'avg_sleep', 'avg_stress', 'avg_mood', 'avg_calories']]

# 3. Preprocessing
scaler = StandardScaler()
scaled_data = scaler.fit_transform(X)

# 4. K-Means Training (K=3)
kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
df['cluster'] = kmeans.fit_predict(scaled_data)

# 5. Labeling the Clusters (Identifying which ID belongs to which lifestyle)
X_labeled = X.copy()
X_labeled['cluster'] = df['cluster']
cluster_means = X_labeled.groupby('cluster').mean()
labels = {}
for i in range(3):
    row = cluster_means.loc[i]
    if row['avg_steps'] > 8500 and row['avg_stress'] < 4:
        labels[i] = "High-Energy Achiever"
    elif row['avg_stress'] > 5:
        labels[i] = "Stressed Overworker"
    else:
        labels[i] = "Sedentary/Relaxed"

# 6. Save Model, Scaler and Labels
joblib.dump(kmeans, 'model/lifestyle_cluster_model.pkl')
joblib.dump(scaler, 'model/lifestyle_scaler.pkl')
joblib.dump(labels, 'model/cluster_labels.pkl')

print("✅ Clustering Model Trained Successfully!")
print(f"Cluster Mappings: {labels}")
