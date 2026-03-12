import tensorflow as tf
import numpy as np
import sys
from pathlib import Path
from tensorflow.keras.preprocessing import image

# Path to trained model
MODEL_PATH = "models/20260313-003259/final_model.keras"
CLASS_PATH = "models/20260313-003259/class_names.txt"

# Load model
model = tf.keras.models.load_model(MODEL_PATH)

# Load class names
with open(CLASS_PATH) as f:
    class_names = [line.strip() for line in f]

# Get image path from command line
img_path = sys.argv[1]

# Load image
img = image.load_img(img_path, target_size=(224,224))
img_array = image.img_to_array(img)
img_array = np.expand_dims(img_array, axis=0)

# Normalize
img_array = img_array / 255.0

# Predict
pred = model.predict(img_array)

predicted_class = class_names[np.argmax(pred)]

print("Predicted Food:", predicted_class)