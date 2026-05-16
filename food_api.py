from flask import Flask, request, jsonify
from predict_food_api import analyze_image
import time

app = Flask(__name__)

@app.route("/api/food/analyze", methods=["POST"])
def analyze():
    start = time.time()

    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    img_start = time.time()

    file = request.files["image"]
    path = "temp.jpg"
    file.save(path)

    print("📸 Image save time:", time.time() - img_start)

    pred_start = time.time()

    result = analyze_image(path)

    print("🧠 Prediction + processing time:", time.time() - pred_start)

    total = time.time() - start
    print("⏱ Total API time:", total)

    if isinstance(result, dict) and result.get("error"):
        print(f"[ERROR] analyze_image returned error: {result['error']}")
        return jsonify(result), 500

    return jsonify(result)


# ✅ ADD THIS HERE (NEW ENDPOINT)
@app.route("/api/food/manual", methods=["POST"])
def manual_food():
    data = request.get_json()

    if not data:
        return jsonify({"error": "No JSON body found"}), 400

    food = data.get("food", "").lower().strip()

    if not food:
        return jsonify({"error": "Food name missing"}), 400

    # Example response (replace with your nutrition logic)
    return jsonify({
        "food": food,
        "calories": 100,   # dummy values for now
        "protein": 5,
        "carbs": 20
    })

@app.route('/save_diet_score', methods=['POST'])
def save_diet_score():
    data = request.json
    try:
        user_id = data['userId']
        level_id = data['levelId']
        diet_score = data['dietScore']

        print(f"Saving diet score: user={user_id}, level={level_id}, score={diet_score}")

        return jsonify({
            "status": "success",
            "message": "Diet score saved successfully"
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        })
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003, debug=True)