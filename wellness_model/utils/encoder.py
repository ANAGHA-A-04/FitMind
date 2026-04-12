def mood_to_number(mood):
    mood = str(mood).capitalize()
    return {
        "Sad": 0,
        "Neutral": 1,
        "Happy": 2
    }.get(mood, 1)

def number_to_state(label):
    return {
        0: "Stressed",
        1: "Balanced",
        2: "Healthy"
    }.get(label, "Balanced")
