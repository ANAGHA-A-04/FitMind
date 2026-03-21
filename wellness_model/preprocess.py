import pandas as pd

def load_and_preprocess():
    df = pd.read_csv("dataset/wellness_data.csv")

    #for ensuring the correct columns in the csv file
    df = df[['steps','sleep','mood','label']]

    # to handle the missing values
    df = df.dropna()

    return df