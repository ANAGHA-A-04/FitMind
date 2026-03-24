
# Purpose:
#   Flask REST API server that exposes the chatbot as an HTTP endpoint.
#
#   Endpoint:
#     POST /chat
#       Request body  : { "message": "I feel stressed" }
#       Response body : { "reply": "Try deep breathing for five minutes." }
#
# The Flutter mobile app will call this endpoint from its chat screen.
#
# Prerequisites:
#   1. pip install -r requirements.txt
#   2. python train_model.py          ← must be run first to create model files
#   3. python app.py                  ← starts the server on port 5000


from flask import Flask, request, jsonify
from chatbot_model import chatbot_response


app = Flask(__name__)



@app.route("/chat", methods=["POST"])
def chat():
    """
    Handle a chat request from the Flutter app (or any HTTP client).

    Expects JSON body:
        { "message": "<user text>" }

    Returns JSON body:
        { "reply": "<chatbot response>" }
        or
        { "error": "<description>" }  with HTTP 400 if input is missing/invalid.
    """
    # --- Parse incoming JSON ---
    data = request.get_json(silent=True)

    if not data or "message" not in data:
        return jsonify({
            "error": "Invalid request. Please send JSON with a 'message' key."
        }), 400

    user_message = data["message"].strip()

    if not user_message:
        return jsonify({
            "error": "Message cannot be empty."
        }), 400

    # --- Generate chatbot reply ---
    # chatbot_response() handles preprocessing, TF-IDF transform,
    # intent prediction, and random response selection.
    reply = chatbot_response(user_message)

    return jsonify({"reply": reply}), 200




@app.route("/", methods=["GET"])
def health_check():
    """Simple health check — returns server status."""
    return jsonify({
        "status": "running",
        "service": "FitMind Wellness Chatbot API",
        "version": "1.0.0",
        "endpoint": "POST /chat  →  { message: '...' }"
    }), 200



if __name__ == "__main__":
    print("\n" + "=" * 55)
    print("  FitMind Wellness Chatbot API")
    print("  Running at: http://127.0.0.1:5001")
    print("  Endpoint  : POST /chat")
    print("=" * 55 + "\n")

    # debug=False for production-like behaviour.
    # host="0.0.0.0" makes the server reachable from the device running Flutter.
    app.run(host="0.0.0.0", port=5001, debug=True)
