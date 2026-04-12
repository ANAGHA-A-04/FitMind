from flask import Flask, request,jsonify
from predict import predict_state
from predict_cluster import predict_lifestyle

app = Flask(__name__)

@app.route('/')
def home():
    return "Mental wellness api running"

@app.route('/predict_cluster', methods=['POST'])
def predict_cluster():
    data = request.json
    try:
        steps = data['steps']
        sleep = data['sleep']
        stress = data['stress']
        mood = data['mood']
        calories = data['calories']

        result = predict_lifestyle(steps, sleep, stress, mood, calories)

        return jsonify({
            "status": "success",
            "lifestyle_cluster": result
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        })

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
    app.run(host='0.0.0.0', port=5002, debug=True)