import os
import pandas as pd
import subprocess
import sys

def main():
    print("Installing openpyxl...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "openpyxl", "scikit-learn", "pandas"])

    print("Creating dataset directory...")
    os.makedirs('dataset', exist_ok=True)
    
    print("Converting excel to csv...")
    try:
        df = pd.read_excel('wellness_data.csv.xlsx')
        df.to_csv('dataset/wellness_data.csv', index=False)
        print("Success: wellness_data.csv created!")
    except Exception as e:
        print(f"Error reading excel: {e}")
        return

    print("Training model...")
    result = subprocess.run([sys.executable, "train_model.py"], capture_output=True, text=True)
    print("STDOUT:", result.stdout)
    print("STDERR:", result.stderr)

if __name__ == '__main__':
    main()
