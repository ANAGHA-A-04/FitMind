import joblib
import pandas as pd
import os

# Paths to models
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, '..', 'lifestyle_clustering', 'model')

MODEL_PATH = os.path.join(MODEL_DIR, 'lifestyle_cluster_model.pkl')
SCALER_PATH = os.path.join(MODEL_DIR, 'lifestyle_scaler.pkl')
LABELS_PATH = os.path.join(MODEL_DIR, 'cluster_labels.pkl')

def predict_lifestyle(steps, sleep, stress, mood, calories):
    try:
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        labels = joblib.load(LABELS_PATH)
        
        # Prepare data
        data = pd.DataFrame([{
            'avg_steps': steps,
            'avg_sleep': sleep,
            'avg_stress': stress,
            'avg_mood': mood,
            'avg_calories': calories
        }])
        
        # Scale data
        scaled_data = scaler.transform(data)
        
        # Predict
        cluster_id = model.predict(scaled_data)[0]
        lifestyle = labels.get(cluster_id, "Unknown Lifestyle")
        
        return lifestyle
    except Exception as e:
        return str(e)
