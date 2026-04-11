import os

model_dir = r'C:\Users\LENOVO\FitMind\app_model.keras'

print(f"Model directory: {model_dir}")
print(f"Directory exists: {os.path.isdir(model_dir)}")
print(f"Directory readable: {os.access(model_dir, os.R_OK)}")

try:
    files = os.listdir(model_dir)
    print(f"Files in directory: {files}")
    for f in files:
        filepath = os.path.join(model_dir, f)
        print(f"  {f}: readable={os.access(filepath, os.R_OK)}")
except Exception as e:
    print(f"Error listing directory: {e}")

# Try to open the config file
try:
    with open(os.path.join(model_dir, 'config.json'), 'r') as f:
        content = f.read(100)
        print(f"\nSuccessfully read config.json")
except Exception as e:
    print(f"\nError reading config.json: {e}")
