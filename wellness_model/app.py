from flask import Flask, request,jsonify
from predict import predict_state

app = Flask(__name__)

@app.route('/')
def home():
    return "Mental wellness api running"

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json

    try:
        steps = data['steps']
        sleep = data['sleep']
        stress = data['stress']
        mood = data['mood']

        result = predict_state(steps, sleep, stress, mood)

        return jsonify({
            "status": "success",
            "mental_state": result
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        })
if __name__ == '__main__' :
    app.run(debug=True)