from flask import Flask, request, jsonify
from pymongo import MongoClient
from bson import ObjectId
from bson.errors import InvalidId
from dotenv import load_dotenv
import os
from pathlib import Path

# Load .env file from the same directory as app.py
load_dotenv()

app = Flask(__name__)

# =========================
# MongoDB Connection
# =========================

# Get MongoDB URI from environment variable
MONGO_URI = os.getenv("MONGO_URI")

# Fallback to hardcoded URI if .env doesn't have it (for testing)
if not MONGO_URI:
    MONGO_URI = "mongodb+srv://fitmindadmin:application@clusterfit.l8gxnd5.mongodb.net/?appName=Clusterfit"
    print("⚠️ Using hardcoded MongoDB URI (MONGO_URI not found in .env)")

try:
    client = MongoClient(
        MONGO_URI,
        serverSelectionTimeoutMS=5000,
        connectTimeoutMS=5000,
    )
    
    # Test the connection
    client.admin.command("ping")
    
    db = client["fitmind"]
    print("✅ MongoDB Connected Successfully")

except Exception as e:
    print("❌ MongoDB Connection Error:", e)
    client = None
    db = None


# =========================
# Adaptive Task Builder
# =========================

def build_tasks(goal, wellness_score, diet_score):
    tasks = []

    # REDUCE WEIGHT
    if goal == "reduce weight":

        if wellness_score < 50:
            tasks += [
                "Do 10 minutes of breathing exercise.",
                "Sleep before 11 PM tonight.",
                "Walk at least 6000 steps."
            ]
        else:
            tasks += [
                "Maintain a 7000+ step target.",
                "Avoid sugary drinks today."
            ]

        if diet_score < 50:
            tasks += [
                "Choose a low-calorie meal.",
                "Avoid fried food today.",
                "Drink water before meals."
            ]
        else:
            tasks += [
                "Keep portion sizes controlled.",
                "Add one high-fiber snack."
            ]

    # MAINTAIN FITNESS
    elif goal == "maintain fitness":

        if wellness_score < 50:
            tasks += [
                "Take a short walk after lunch.",
                "Do 5 minutes of mindful breathing."
            ]
        else:
            tasks += [
                "Continue your current workout routine.",
                "Maintain a consistent sleep schedule."
            ]

        if diet_score < 50:
            tasks += [
                "Replace one meal with a balanced plate.",
                "Add vegetables to lunch or dinner."
            ]
        else:
            tasks += [
                "Keep protein and carbs balanced.",
                "Stay hydrated throughout the day."
            ]

    # INCREASE WEIGHT
    elif goal == "increase weight":

        if wellness_score < 50:
            tasks += [
                "Prioritize rest and sleep.",
                "Do light activity only today."
            ]
        else:
            tasks += [
                "Maintain light exercise and recovery.",
                "Keep stress under control."
            ]

        if diet_score < 50:
            tasks += [
                "Eat one extra meal or snack today.",
                "Include calorie-dense foods like nuts or banana.",
                "Add protein with each meal."
            ]
        else:
            tasks += [
                "Continue calorie surplus plan.",
                "Include a protein shake or snack."
            ]

    # DEFAULT
    else:
        tasks += [
            "Drink enough water today.",
            "Walk for 20 minutes.",
            "Maintain a balanced meal."
        ]

    # Remove duplicates
    return list(dict.fromkeys(tasks))


# =========================
# Generate Tasks API
# =========================

@app.route("/generate_tasks", methods=["POST"])
def generate_tasks():

    try:
        data = request.get_json()

        print("\n" + "="*50)
        print("📥 ADAPTIVE ENGINE: Incoming Request")
        print("="*50)
        print("Raw data:", data)
        print("Data type:", type(data))
        print("="*50 + "\n")

        # -------------------------
        # Validate Request
        # -------------------------

        if not data:
            print("❌ Invalid or missing JSON body")
            return jsonify({
                "status": "error",
                "message": "Invalid or missing JSON body"
            }), 400

        user_id = data.get("userId")
        wellness_score = data.get("wellnessScore")
        diet_score = data.get("dietScore")

        print("🔍 Extracted fields:")
        print(f"  userId: '{user_id}' (type: {type(user_id)}, len: {len(str(user_id)) if user_id else 'NULL'})")
        print(f"  wellnessScore: {wellness_score} (type: {type(wellness_score)})")
        print(f"  dietScore: {diet_score} (type: {type(diet_score)})")
        print()

        # -------------------------
        # Missing Field Check
        # -------------------------

        missing_fields = []

        if user_id is None:
            missing_fields.append("userId")

        if wellness_score is None:
            missing_fields.append("wellnessScore")

        if diet_score is None:
            missing_fields.append("dietScore")

        if missing_fields:
            print(f"❌ Missing fields: {missing_fields}")
            return jsonify({
                "status": "error",
                "message": f"Missing field(s): {', '.join(missing_fields)}"
            }), 400

        # -------------------------
        # Convert Scores
        # -------------------------

        try:
            wellness_score = int(wellness_score)
            diet_score = int(diet_score)
            print(f"✅ Converted scores: wellness={wellness_score}, diet={diet_score}")

        except ValueError as e:
            print(f"❌ Score conversion error: {e}")
            return jsonify({
                "status": "error",
                "message": "Scores must be integers"
            }), 400

        # -------------------------
        # Validate MongoDB ObjectId
        # -------------------------

        print(f"\n🔄 Converting userId to ObjectId...")
        print(f"  Input: '{user_id}' (type: {type(user_id)})")
        
        try:
            object_user_id = ObjectId(user_id)
            print(f"✅ ObjectId created: {object_user_id}")

        except InvalidId as e:
            print(f"❌ Invalid ObjectId format: {e}")
            return jsonify({
                "status": "error",
                "message": f"Invalid userId format: {e}"
            }), 400

        # -------------------------
        # Database Check
        # -------------------------

        if db is None:
            print("❌ Database unavailable")
            return jsonify({
                "status": "error",
                "message": "Database unavailable"
            }), 500

        # -------------------------
        # Find User
        # -------------------------

        print(f"\n🔎 Querying MongoDB...")
        print(f"  Collection: fitmind.users")
        print(f"  Query: {{'_id': ObjectId('{object_user_id}')}}")
        
        user = db.users.find_one({
            "_id": object_user_id
        })

        if user:
            print(f"✅ User found!")
            print(f"  _id: {user.get('_id')}")
            print(f"  name: {user.get('name')}")
            print(f"  email: {user.get('email')}")
            print(f"  goal: {user.get('goal')}")
        else:
            print(f"❌ User NOT found in database")
            print(f"  Searched for _id: {object_user_id}")
            # Try to list all users for debugging
            print(f"\n📋 Available users in database:")
            all_users = db.users.find()
            for u in all_users:
                print(f"    _id: {u.get('_id')}, name: {u.get('name')}, email: {u.get('email')}")

        if not user:
            return jsonify({
                "status": "error",
                "message": "User not found"
            }), 404

        # -------------------------
        # Fetch Goal
        # -------------------------

        goal = user.get("goal", "maintain fitness")

        print("🎯 User Goal:", goal)

        # -------------------------
        # Generate Tasks
        # -------------------------

        tasks = build_tasks(
            goal,
            wellness_score,
            diet_score
        )

        print("✅ Generated Tasks:", tasks)

        # -------------------------
        # Success Response
        # -------------------------

        return jsonify({
            "status": "success",
            "userId": str(user_id),
            "goal": goal,
            "wellnessScore": wellness_score,
            "dietScore": diet_score,
            "tasks": tasks
        })

    except Exception as e:

        print("❌ SERVER ERROR:", str(e))

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


# =========================
# Run Flask App
# =========================

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5004,
        debug=True
    )