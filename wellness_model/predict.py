import joblib
from utils.encoder import number_to_state

#load model once
model = joblib.load('model/mental_wellness_model.pkl')

def predict_state(steps, sleep, stress, mood):
    input_data = [[steps, sleep, stress, mood]]

    prediction =model.predict(input_data)[0]

    return number_to_state(prediction)