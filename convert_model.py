import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import json

def build_model(num_classes, image_size=(224, 224)):
    """Rebuild the model architecture from train_food_model.py"""
    inputs = keras.Input(shape=(*image_size, 3))
    x = layers.Rescaling(1.0 / 255)(inputs)
    
    # Data augmentation
    x = layers.RandomFlip("horizontal")(x)
    x = layers.RandomRotation(0.1)(x)
    x = layers.RandomZoom(0.15)(x)
    
    # Block 1
    x = layers.Conv2D(32, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(32, (3, 3), activation="relu")(x)
    x = layers.MaxPooling2D()(x)
    
    # Block 2
    x = layers.Conv2D(64, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(64, (3, 3), activation="relu")(x)
    x = layers.MaxPooling2D()(x)
    
    # Block 3
    x = layers.Conv2D(128, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(128, (3, 3), activation="relu")(x)
    x = layers.MaxPooling2D()(x)
    
    # Block 4
    x = layers.Conv2D(256, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.MaxPooling2D()(x)
    
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dense(256, activation="relu")(x)
    x = layers.Dropout(0.5)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)
    
    model = keras.Model(inputs, outputs)
    return model


# Load metadata to get class count
model_dir = 'models/20260315-111204/final_model.keras'
metadata_file = os.path.join(model_dir, 'metadata.json')

try:
    with open(metadata_file, 'r') as f:
        metadata = json.load(f)
        config = json.loads(metadata['config'])
        num_classes = config['config']['layers'][-1]['config']['units']
        print(f"Number of classes: {num_classes}")
except Exception as e:
    print(f"Error reading metadata: {e}")
    # Fallback: try to infer from config
    config_file = os.path.join(model_dir, 'config.json')
    with open(config_file, 'r') as f:
        config_data = json.load(f)
        # Try to find the output layer
        for layer in reversed(config_data['config']['layers']):
            if layer['class_name'] == 'Dense' and layer['config']['activation'] == 'softmax':
                num_classes = layer['config']['units']
                print(f"Number of classes (from config): {num_classes}")
                break

# Build new model
model = build_model(num_classes)

# Load weights
weights_file = os.path.join(model_dir, 'model.weights.h5')
try:
    model.load_weights(weights_file)
    print(f"Loaded weights from {weights_file}")
except Exception as e:
    print(f"Error loading weights: {e}")

# Save in HDF5 format for compatibility
output_model = 'app_model.h5'
model.save(output_model, save_format='h5')
print(f"Saved model to {output_model}")
