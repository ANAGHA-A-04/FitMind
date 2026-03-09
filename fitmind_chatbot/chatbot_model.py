# =============================================================================
# chatbot_model.py
# FitMind – AI Driven Fitness and Mental Wellness System
# -----------------------------------------------------------------------------
# Purpose:
#   This module contains:
#     1. Text preprocessing functions
#     2. The chatbot response function (loads model, predicts intent, returns reply)
#
# AI Approach: TF-IDF + Logistic Regression (classic NLP — no external AI APIs)
# =============================================================================

import re
import json
import pickle
import random
import os
import numpy as np

# --------------------------------------------------------------------------
# CONSTANTS — paths to saved model files (produced by train_model.py)
# --------------------------------------------------------------------------
MODEL_PATH      = "model.pkl"
VECTORIZER_PATH = "vectorizer.pkl"
INTENTS_PATH    = "intents.json"


# =============================================================================
# STEP 2 — TEXT PREPROCESSING
# =============================================================================
# Why preprocess?
#   Raw user input contains noise: mixed cases, punctuation, extra spaces.
#   Preprocessing normalises text so that "I'm Stressed!" and "i am stressed"
#   are treated as similar by the vectoriser and classifier.
#
#   Steps applied:
#     • Lowercase  → removes case sensitivity ("Stress" == "stress")
#     • Remove punctuation → strips symbols that carry no semantic meaning
#       (e.g. "stressed!" → "stressed")
#     • Strip extra whitespace → clean token boundaries for TF-IDF

def preprocess(text: str) -> str:
    """
    Normalise raw user text before feeding it into the TF-IDF vectoriser.

    Args:
        text (str): Raw input string from the user.

    Returns:
        str: Cleaned, lowercase string without punctuation.
    """
    # 1. Convert everything to lowercase
    text = text.lower()

    # 2. Remove all punctuation characters using a regular expression.
    #    [^\w\s] matches any character that is NOT a word character or whitespace.
    text = re.sub(r"[^\w\s]", "", text)

    # 3. Collapse multiple spaces into a single space and strip leading/trailing
    text = re.sub(r"\s+", " ", text).strip()

    return text


# =============================================================================
# MODEL LOADER — loads the saved vectoriser and classifier from disk
# =============================================================================
# We save the trained model with pickle so the Flask server never needs to
# retrain on every restart.  We load them once into module-level variables.

def _load_artifacts():
    """
    Load the TF-IDF vectoriser, Logistic Regression model, and intents JSON
    from disk.  Called once at import time.

    Returns:
        tuple: (vectorizer, model, intents_data)

    Raises:
        FileNotFoundError: if train_model.py has not been run yet.
    """
    if not os.path.exists(MODEL_PATH) or not os.path.exists(VECTORIZER_PATH):
        raise FileNotFoundError(
            "Trained model files not found.\n"
            "Please run:  python train_model.py  first."
        )

    with open(VECTORIZER_PATH, "rb") as f:
        vectorizer = pickle.load(f)

    with open(MODEL_PATH, "rb") as f:
        model = pickle.load(f)

    with open(INTENTS_PATH, "r", encoding="utf-8") as f:
        intents_data = json.load(f)

    return vectorizer, model, intents_data


# Load once when the module is imported (so Flask does not reload on each request)
_vectorizer, _model, _intents_data = _load_artifacts()

# Build a quick lookup dict:  { tag -> [responses] }
_responses_map: dict[str, list[str]] = {
    intent["tag"]: intent["responses"]
    for intent in _intents_data["intents"]
}


# =============================================================================
# STEP 6 — CHATBOT PREDICTION FUNCTION
# =============================================================================
# Pipeline:
#   user_input
#     → preprocess()            (lowercase, remove punctuation)
#     → TF-IDF vectoriser       (converts text to numerical feature vector)
#     → Logistic Regression     (predicts the intent label)
#     → responses_map[intent]   (look up possible responses for that intent)
#     → random.choice()         (return one response at random for variety)

def chatbot_response(user_input: str) -> str:
    """
    Generate a wellness chatbot response for the given user message.

    Steps:
        1. Preprocess the user message (lowercase + remove punctuation).
        2. Convert the cleaned text to a TF-IDF feature vector.
        3. Predict the intent label with the Logistic Regression classifier.
        4. Retrieve all candidate responses for that intent.
        5. Randomly select one response to keep replies varied.
        6. Print debug logs to the terminal for demonstration purposes.

    Args:
        user_input (str): Raw message sent by the user.

    Returns:
        str: A relevant wellness response from the predicted intent.
    """
    # --- Step 1: Preprocess ---
    cleaned = preprocess(user_input)

    # --- Step 2: TF-IDF vectorisation ---
    # The vectoriser transforms the cleaned string into a sparse numeric matrix
    # using the same vocabulary it learned during training.
    X = _vectorizer.transform([cleaned])

    # --- Step 3: Predict intent ---
    predicted_intent = _model.predict(X)[0]

    # --- Step 4 & 5: Retrieve confidence and pick a random response ---
    # predict_proba() returns the probability for every class.
    # We take the max value as the confidence score.
    probabilities   = _model.predict_proba(X)[0]
    confidence      = float(np.max(probabilities))

    responses = _responses_map.get(
        predicted_intent,
        ["I'm sorry, I didn't quite understand that. Could you rephrase?"]
    )
    reply = random.choice(responses)

    # --- Step 7: Debug logs for terminal demonstration ---
    print("\n" + "=" * 55)
    print(f"  User input       : {user_input}")
    print(f"  Predicted intent : {predicted_intent}")
    print(f"  Confidence       : {confidence:.2f}")
    print(f"  Bot response     : {reply}")
    print("=" * 55 + "\n")

    return reply
