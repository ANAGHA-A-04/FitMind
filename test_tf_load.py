import os
import sys

# Test TensorFlow model loading
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

import tensorflow as tf
print(f"TensorFlow version: {tf.__version__}")

model_path = r'C:\Users\LENOVO\FitMind\app_model.keras'

print(f"\nTrying to load model from: {model_path}")
print(f"Path exists: {os.path.exists(model_path)}")

try:
    # Try using absolute path
    model = tf.keras.models.load_model(os.path.abspath(model_path))
    print("Successfully loaded model with absolute path")
except Exception as e:
    print(f"Error with absolute path: {type(e).__name__}: {e}")
    
try:
    # Try using the path as-is
    model = tf.keras.models.load_model(model_path)
    print("Successfully loaded model with raw path")
except Exception as e:
    print(f"Error with raw path: {type(e).__name__}: {e}")
