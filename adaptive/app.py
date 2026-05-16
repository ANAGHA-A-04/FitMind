from flask import Flask, request, jsonify
from pymongo import MongoClient
from bson import ObjectId
from bson.errors import InvalidId
from dotenv import load_dotenv
import os
from pathlib import Path
from datetime import datetime

# Load .env file from the same directory as app.py
load_dotenv()

app = Flask(__name__)

# =========================
# MongoDB Connection
# =========================

# Get MongoDB URI from environment variable (support both names)
MONGO_URI = os.getenv("MONGO_URI") or os.getenv("MONGODB_URI")

# Fallback to hardcoded URI if no env var provided (only for quick testing)
if not MONGO_URI:
    MONGO_URI = "mongodb+srv://fitmindadmin:application@clusterfit.l8gxnd5.mongodb.net/test?appName=Clusterfit"
    print("⚠️ Using hardcoded MongoDB URI (no MONGO_URI or MONGODB_URI found in .env)")

try:
    client = MongoClient(
        MONGO_URI,
        serverSelectionTimeoutMS=5000,
        connectTimeoutMS=5000,
    )
    
    # Test the connection
    client.admin.command("ping")
    
    db = client["test"]
    print("✅ MongoDB Connected Successfully to 'test' database")

except Exception as e:
    print("❌ MongoDB Connection Error:", e)
    client = None
    db = None


# =========================
# Adaptive Task Builder (Enhanced)
# =========================

def build_tasks(goal, wellness_score, diet_score, level=1, completion_percentage=100):
    """
    Build adaptive tasks based on:
    - goal: User's fitness goal
    - wellness_score: Current wellness state (0-100)
    - diet_score: Current diet state (0-100)
    - level: Current level (for difficulty scaling)
    - completion_percentage: Previous level completion (for adaptation)
    """
    
    tasks = []
    
    # =========================
    # DIFFICULTY SCALING
    # =========================
    
    # If user completed <40% last level, reduce difficulty
    # If user completed >70% last level, increase difficulty
    difficulty_modifier = 1.0
    
    if completion_percentage < 40:
        difficulty_modifier = 0.7  # Reduce difficulty by 30%
    elif completion_percentage > 70:
        difficulty_modifier = 1.3 + (level * 0.1)  # Increase by 30% + level scaling
    
    # Level-based difficulty scaling
    level_factor = 1.0 + (level * 0.15)
    final_difficulty = difficulty_modifier * level_factor
    
    print(f"\n📊 DIFFICULTY ANALYSIS:")
    print(f"  Previous completion: {completion_percentage}%")
    print(f"  Level: {level}")
    print(f"  Difficulty modifier: {difficulty_modifier}")
    print(f"  Final difficulty factor: {final_difficulty}")

    # =========================
    # STEP TARGET SCALING
    # =========================
    
    base_steps = 6000
    steps_target = int(base_steps * final_difficulty)
    
    minutes_target = 10
    if completion_percentage > 70:
        minutes_target = int(minutes_target * 1.2 + level)
    
    water_target = 8
    if wellness_score > 70:
        water_target = 12
    
    # =========================
    # TASK GENERATION BASED ON GOAL
    # =========================

    if goal == "reduce weight":
        # Wellness tasks
        if wellness_score < 40:  # Stressed/Low
            tasks += [
                f"Do 10 minutes of breathing exercise.",
                "Sleep before 11 PM tonight.",
                "Do 10 minutes of light stretching.",
                f"Walk at least {steps_target} steps."
            ]
        elif wellness_score < 70:  # Balanced
            tasks += [
                f"Maintain a {steps_target} step target.",
                "Go for a 15-minute jog.",
                f"Do {minutes_target} minutes of light cardio."
            ]
        else:  # Active/High
            tasks += [
                f"Hit {steps_target + 1000} step challenge today.",
                "Do 20 minutes of intense workout.",
                "Complete a 15-minute HIIT session.",
                f"Complete {minutes_target + 5} minutes of strength training."
            ]
        
        # Diet tasks
        if diet_score < 40:  # Poor diet
            tasks += [
                "Choose a low-calorie meal under 300 calories.",
                "Avoid fried food today.",
                "Drink water before meals."
            ]
        elif diet_score < 70:  # Moderate diet
            tasks += [
                "Keep portion sizes controlled.",
                "Add one high-fiber snack (at least 5g fiber).",
                f"Drink {water_target} glasses of water."
            ]
        else:  # Good diet
            tasks += [
                "Maintain calorie deficit (under 2000 cal).",
                "Add 2 servings of vegetables.",
                f"Drink {water_target + 2} glasses of water."
            ]

    # MAINTAIN FITNESS
    elif goal == "maintain fitness":
        if wellness_score < 40:
            tasks += [
                "Take a short walk after lunch.",
                "Do 5 minutes of mindful breathing.",
                f"Walk {steps_target - 1000} steps."
            ]
        elif wellness_score < 70:
            tasks += [
                f"Maintain {steps_target} step consistency.",
                f"Exercise for {minutes_target} minutes.",
                "Do 15 minutes of bodyweight exercises (squats, lunges).",
                "Do light stretching or yoga."
            ]
        else:
            tasks += [
                f"Hit {steps_target + 1500} steps.",
                f"Complete {minutes_target + 10} minutes of structured workout.",
                "Do a 10-minute core workout.",
                "Do 20 jumping jacks and 10 pushups.",
                "Try a new physical activity."
            ]
        
        if diet_score < 40:
            tasks += [
                "Replace one meal with a balanced plate.",
                "Add vegetables to lunch or dinner.",
                f"Drink {water_target} glasses of water."
            ]
        elif diet_score < 70:
            tasks += [
                "Keep protein and carbs balanced (30/40 ratio).",
                "Stay hydrated throughout the day.",
                "Add one lean protein source."
            ]
        else:
            tasks += [
                "Maintain clean eating streak.",
                "Include 3 different colored vegetables today.",
                f"Drink {water_target} glasses of water."
            ]

    # INCREASE WEIGHT
    elif goal == "increase weight":
        if wellness_score < 40:
            tasks += [
                "Prioritize rest and sleep (8+ hours).",
                "Do light activity only today.",
                "Do 5 minutes of mobility exercises.",
                "Avoid intense workouts."
            ]
        elif wellness_score < 70:
            tasks += [
                "Maintain light exercise and recovery.",
                "Do 3 sets of 10 pushups.",
                "Keep stress under control.",
                f"Walk {int(steps_target * 0.5)} steps for circulation."
            ]
        else:
            tasks += [
                f"Do {minutes_target} minutes of strength training.",
                f"Hit {int(steps_target * 0.7)} step target.",
                "Perform 4 sets of compound lifts (squats/deadlifts).",
                "Do progressive resistance exercises."
            ]
        
        if diet_score < 40:
            tasks += [
                "Eat one extra meal or snack (500+ cal).",
                "Include calorie-dense foods (nuts, banana, olive oil).",
                "Add protein with each meal (20g+ per meal)."
            ]
        elif diet_score < 70:
            tasks += [
                "Continue calorie surplus plan (+300 cal/day).",
                "Include a protein shake or snack (30g protein).",
                f"Drink {water_target} glasses of water."
            ]
        else:
            tasks += [
                "Maintain aggressive calorie surplus (+500 cal/day).",
                "Include 2 high-calorie snacks per day.",
                f"Consume 2g protein per kg of body weight."
            ]

    # DEFAULT/FALLBACK
    else:
        tasks += [
            f"Drink {water_target} glasses of water.",
            f"Walk {steps_target} steps.",
            "Maintain a balanced meal."
        ]

    # Remove duplicates while preserving order
    seen = set()
    unique_tasks = []
    for task in tasks:
        if task not in seen:
            unique_tasks.append(task)
            seen.add(task)
    
    return unique_tasks


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
        previous_level = data.get("previousLevel", 1)
        previous_completion = data.get("previousCompletion", 100)

        print("🔍 Extracted fields:")
        print(f"  userId: '{user_id}' (type: {type(user_id)}, len: {len(str(user_id)) if user_id else 'NULL'})")
        print(f"  wellnessScore: {wellness_score} (type: {type(wellness_score)})")
        print(f"  dietScore: {diet_score} (type: {type(diet_score)})")
        print(f"  previousLevel: {previous_level}")
        print(f"  previousCompletion: {previous_completion}%")
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
            print(f"  ObjectId string: {str(object_user_id)}")
            
            # Try to list all users for debugging
            print(f"\n📋 Available users in database:")
            all_users = list(db.users.find())
            print(f"  Total users: {len(all_users)}")
            for u in all_users:
                uid = u.get('_id')
                print(f"    _id: {uid} (type: {type(uid).__name__})")
                print(f"      id string: {str(uid)}")
                print(f"      name: {u.get('name')}, email: {u.get('email')}")

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
            diet_score,
            level=previous_level,
            completion_percentage=previous_completion
        )

        print("✅ Generated Tasks:", tasks)

        # -------------------------
        # Ensure UserStats exists (for existing users)
        # -------------------------
        try:
            existing_stats = db.userStats.find_one({"userId": object_user_id})
            
            if not existing_stats:
                print(f"📊 Creating UserStats for existing user...")
                user_stats_doc = {
                    "userId": object_user_id,
                    "currentLevel": 0,
                    "totalXP": 0,
                    "averageCompletionPercentage": 0,
                    "totalCompletions": 0,
                    "lastCompletionDate": datetime.utcnow()
                }
                insert_result = db.userStats.insert_one(user_stats_doc)
                print(f"✅ UserStats created with _id: {insert_result.inserted_id}")
            else:
                print(f"✅ UserStats already exists for user")
        except Exception as e:
            print(f"⚠️ Failed to create/check UserStats: {e}")

        # -------------------------
        # Persist scores
        # -------------------------
        try:
            score_doc = {
                "userId": object_user_id,
                "wellnessScore": wellness_score,
                "dietScore": diet_score,
                "tasks": tasks,
                "createdAt": datetime.utcnow()
            }

            insert_result = db.scores.insert_one(score_doc)
            print(f"✅ Saved score document with _id: {insert_result.inserted_id}")
        except Exception as e:
            print("⚠️ Failed to save score document:", e)

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