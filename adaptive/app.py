from flask import Flask, request, jsonify
from pymongo import MongoClient
from bson import ObjectId
from bson.errors import InvalidId
from dotenv import load_dotenv
import os
from pathlib import Path
from datetime import datetime
import random

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

def _clamp(value, min_value, max_value):
    return max(min_value, min(value, max_value))


def _daily_seed(user_id, level):
    today = datetime.utcnow().strftime("%Y-%m-%d")
    return f"{user_id}-{level}-{today}"


def build_tasks(
    goal,
    wellness_score,
    diet_score,
    level=1,
    completion_percentage=100,
    last_completion=None,
    last_wellness=None,
    last_diet=None,
    lifestyle_cluster=None,
    user_id=None,
):
    """
    Build adaptive tasks based on:
    - goal: User's fitness goal
    - wellness_score: Current wellness state (0-100)
    - diet_score: Current diet state (0-100)
    - level: Current level (for difficulty scaling)
    - completion_percentage: Previous level completion (for adaptation)
    """
    
    tasks = []

    # Normalize optional inputs
    if last_completion is None:
        last_completion = completion_percentage

    wellness_trend = 0
    diet_trend = 0
    if last_wellness is not None:
        wellness_trend = wellness_score - last_wellness
    if last_diet is not None:
        diet_trend = diet_score - last_diet
    
    # =========================
    # DIFFICULTY SCALING
    # =========================
    
    # If user completed <40% last level, reduce difficulty
    # If user completed >70% last level, increase difficulty
    difficulty_modifier = 1.0

    if last_completion < 40:
        difficulty_modifier = 0.7  # Reduce difficulty by 30%
    elif last_completion > 70:
        difficulty_modifier = 1.2  # Increase by 20%

    # Level-based difficulty scaling
    level_factor = 1.0 + (level * 0.12)
    final_difficulty = difficulty_modifier * level_factor
    
    print(f"\n📊 DIFFICULTY ANALYSIS:")
    print(f"  Previous completion: {completion_percentage}%")
    print(f"  Level: {level}")
    print(f"  Difficulty modifier: {difficulty_modifier}")
    print(f"  Final difficulty factor: {final_difficulty}")

    # =========================
    # STEP TARGET SCALING
    # =========================
    
    base_steps = 5000
    steps_target = _clamp(int(base_steps * final_difficulty), 3500, 14000)

    minutes_target = _clamp(int(10 * final_difficulty), 8, 35)
    water_target = 8
    if wellness_score > 70:
        water_target = 10
    if diet_score < 40:
        water_target = max(water_target, 9)

    pushups_target = _clamp(int(10 * final_difficulty), 6, 40)
    squats_target = _clamp(int(15 * final_difficulty), 10, 60)
    plank_seconds = _clamp(int(30 * final_difficulty), 20, 120)
    jog_minutes = _clamp(int(8 * final_difficulty), 6, 25)
    
    # =========================
    # TASK GENERATION BASED ON GOAL
    # =========================

    rng_seed = _daily_seed(user_id or "user", level)
    rng = random.Random(rng_seed)

    # Task pools by domain
    physical_low = [
        f"Walk {steps_target} steps today.",
        f"Do {minutes_target} minutes of light stretching.",
        "Do 5 minutes of mobility work.",
        f"Do {pushups_target} wall pushups.",
        "Do 8 chair squats.",
        "Do a 5-minute warm-up walk after meals.",
        "Do 5 minutes of gentle yoga.",
        "Do 10 calf raises.",
    ]
    physical_mid = [
        f"Do {pushups_target} pushups.",
        f"Do {squats_target} squats.",
        f"Jog for {jog_minutes} minutes.",
        f"Complete {minutes_target} minutes of brisk walking.",
        f"Hold a plank for {plank_seconds} seconds.",
        "Do 12 lunges per leg.",
        "Do a 10-minute bodyweight circuit.",
        "Do 3 sets of 12 glute bridges.",
        "Do 2 sets of 20 high knees.",
        "Do 3 sets of 10 mountain climbers.",
    ]
    physical_high = [
        f"Do {pushups_target + 10} pushups.",
        f"Do {squats_target + 15} squats.",
        f"Complete {minutes_target + 10} minutes of workout.",
        f"Do a {plank_seconds + 30}-second plank and 3 sets of crunches.",
        "Do 20 jumping jacks and 10 pushups.",
        "Do a 12-minute HIIT session.",
        "Do 3 sets of burpees (8 reps each).",
        "Do 3 sets of 15 jump squats.",
        "Do 3 sets of 12 tricep dips.",
        "Run or cycle hard for 12 minutes.",
    ]

    mental_low = [
        "Do 5 minutes of mindful breathing.",
        "Write 3 lines in a journal.",
        "Take a 10-minute screen break.",
        "Do a 5-minute body scan relaxation.",
    ]
    mental_mid = [
        "Do a 10-minute meditation.",
        "Practice gratitude: list 5 things.",
        "Do 10 minutes of stretching or yoga.",
    ]
    mental_high = [
        "Do a 15-minute mindfulness session.",
        "Take a 20-minute walk without phone.",
        "Spend 10 minutes on focused breathing and posture reset.",
    ]

    diet_low = [
        f"Drink {water_target} glasses of water.",
        "Add 1 serving of vegetables to a meal.",
        "Avoid sugary drinks today.",
        "Choose a balanced plate for one meal.",
    ]
    diet_mid = [
        f"Drink {water_target} glasses of water.",
        "Include a lean protein source today.",
        "Add one high-fiber snack (5g+ fiber).",
    ]
    diet_high = [
        f"Drink {water_target + 1} glasses of water.",
        "Include 2 different colored vegetables today.",
        "Keep portions controlled and avoid late-night snacking.",
    ]

    # Goal-specific nudges
    if goal == "reduce weight":
        diet_low.append("Choose a low-calorie meal under 350 calories.")
        diet_mid.append("Maintain a calorie deficit for one meal.")
        diet_high.append("Keep daily calories under your target.")
    elif goal == "increase weight":
        diet_low.append("Add one extra snack with protein.")
        diet_mid.append("Add 300 calories through healthy foods.")
        diet_high.append("Include a calorie-dense snack (nuts, yogurt).")
    else:
        diet_mid.append("Balance carbs and protein in one meal.")

    goal_physical = []
    goal_diet = []
    if goal == "reduce weight":
        goal_physical = [
            "Do a 20-minute fat-burn walk.",
            "Complete a 12-minute cardio circuit.",
            "Do 3 rounds: 20 squats, 15 lunges, 20 jumping jacks.",
        ]
        goal_diet = [
            "Keep dinner light and high-protein.",
            "Avoid sugary snacks today.",
        ]
    elif goal == "increase weight":
        goal_physical = [
            "Do 3 sets of slow pushups (8 reps each).",
            "Do 3 sets of controlled squats (10 reps each).",
            "Do 10 minutes of strength-focused bodyweight work.",
        ]
        goal_diet = [
            "Add one calorie-dense snack (nuts, peanut butter).",
            "Include protein at every meal (20g+).",
        ]
    else:
        goal_physical = [
            "Do a 15-minute mixed workout (cardio + strength).",
            "Do a 10-minute core routine.",
        ]
        goal_diet = [
            "Keep meals balanced: protein + fiber + healthy fat.",
        ]

    # Decide intensity buckets
    if wellness_score < 40:
        physical_pool = physical_low
        mental_pool = mental_high
    elif wellness_score < 70:
        physical_pool = physical_mid
        mental_pool = mental_mid
    else:
        physical_pool = physical_high
        mental_pool = mental_mid

    if diet_score < 40:
        diet_pool = diet_low
    elif diet_score < 70:
        diet_pool = diet_mid
    else:
        diet_pool = diet_high

    # Adjust counts based on trends
    physical_count = 3
    mental_count = 2
    diet_count = 2

    if goal == "reduce weight":
        physical_count += 1
        diet_count += 1
    elif goal == "increase weight":
        diet_count += 1
    else:
        physical_count = max(3, physical_count)

    if wellness_score < 40:
        mental_count = 3
        physical_count = 1
    if wellness_trend < -10:
        mental_count += 1
        physical_count = max(1, physical_count - 1)

    if diet_trend < -10:
        diet_count += 1

    # Add small variety boost if completion was high
    if last_completion > 80:
        physical_count += 1

    # Pick tasks without duplicates
    tasks += rng.sample(physical_pool, min(physical_count, len(physical_pool)))
    tasks += rng.sample(mental_pool, min(mental_count, len(mental_pool)))
    tasks += rng.sample(diet_pool, min(diet_count, len(diet_pool)))

    if goal_physical:
        tasks.append(rng.choice(goal_physical))
    if goal_diet:
        tasks.append(rng.choice(goal_diet))

    # Cluster-based adjustment (optional, if provided)
    if lifestyle_cluster:
        if "sedentary" in lifestyle_cluster.lower():
            tasks.append("Stand and stretch for 3 minutes every hour.")
        elif "high-energy" in lifestyle_cluster.lower():
            tasks.append("Add a short burst: 5 x 30-second fast steps.")

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
        lifestyle_cluster = data.get("lifestyleCluster")

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

        # -------------------------
        # Fetch recent completion history
        # -------------------------
        last_completion = None
        last_wellness = None
        last_diet = None

        try:
            recent = list(
                db.completions.find({"userId": object_user_id}).sort("createdAt", -1).limit(2)
            )
            if recent:
                last_completion = recent[0].get("completionPercentage")
                last_wellness = recent[0].get("wellnessScore")
                last_diet = recent[0].get("dietScore")
        except Exception as e:
            print(f"⚠️ Failed to fetch recent completions: {e}")

        tasks = build_tasks(
            goal,
            wellness_score,
            diet_score,
            level=previous_level,
            completion_percentage=previous_completion,
            last_completion=last_completion,
            last_wellness=last_wellness,
            last_diet=last_diet,
            lifestyle_cluster=lifestyle_cluster,
            user_id=str(user_id),
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