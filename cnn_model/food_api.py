import os
import glob

# ✅ Flexible model loading
def find_latest_model():
    """Find the latest model file in models directory"""
    
    # First, check for .keras files in timestamp folders
    model_patterns = [
        "models/*/best_model.keras",
        "models/*/*.keras",
        "models/train/*.keras",
        "models/*/best_model.h5",
        "models/*/*.h5",
    ]
    
    all_models = []
    for pattern in model_patterns:
        all_models.extend(glob.glob(pattern))
    
    if all_models:
        # Return the latest model (by file modification time)
        latest_model = max(all_models, key=os.path.getmtime)
        print(f"Found model: {latest_model}")
        return latest_model
    
    raise FileNotFoundError("No model file found in models directory")

# Find class names file
def find_class_names():
    """Find class_names.txt file"""
    class_patterns = [
        "models/*/class_names.txt",
        "class_names.txt",
        "models/class_names.txt",
    ]
    
    for pattern in class_patterns:
        matches = glob.glob(pattern)
        if matches:
            return matches[0]
    
    raise FileNotFoundError("class_names.txt not found")

# Load model
try:
    MODEL_PATH = find_latest_model()
    print(f"Loading model from: {MODEL_PATH}")
    model = tf.keras.models.load_model(MODEL_PATH)
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    exit(1)

# Load class names
try:
    CLASS_PATH = find_class_names()
    print(f"Loading class names from: {CLASS_PATH}")
    with open(CLASS_PATH) as f:
        class_names = [line.strip() for line in f]
    print(f"Loaded {len(class_names)} classes")
except Exception as e:
    print(f"Error loading class names: {e}")
    exit(1)