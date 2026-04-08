import joblib
from utils.encoder import number_to_state, mood_to_number

#load model once
model = joblib.load('model/mental_wellness_model.pkl')

def predict_state(steps, sleep, stress, mood):
    mood_val = mood_to_number(mood)
    input_data = [[steps, sleep, stress, mood_val]]

    prediction =model.predict(input_data)[0]

    return number_to_state(prediction)