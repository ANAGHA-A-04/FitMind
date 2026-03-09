# =============================================================================
# train_model.py
# FitMind – AI Driven Fitness and Mental Wellness System
# -----------------------------------------------------------------------------
# Purpose:
#   Reads intents.json, preprocesses all training patterns, extracts TF-IDF
#   features, trains a Logistic Regression classifier, evaluates it, and
#   saves the model + vectoriser to disk with pickle.
#
# Run this script ONCE before starting the Flask server:
#   python train_model.py
#
# Output files:
#   vectorizer.pkl  – trained TF-IDF vectoriser
#   model.pkl       – trained Logistic Regression classifier
# =============================================================================

import json
import pickle
import re
import numpy as np

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_score


# =============================================================================
# HELPER — same preprocessing used at prediction time (must stay identical)
# =============================================================================

def preprocess(text: str) -> str:
    """
    Normalise text before TF-IDF vectorisation.

    • Lowercase  → removes case sensitivity
    • Remove punctuation → strips tokens that add noise
    • Collapse whitespace → ensures clean token boundaries
    """
    text = text.lower()
    text = re.sub(r"[^\w\s]", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


# =============================================================================
# STEP 1 — LOAD DATASET
# =============================================================================

print("\n[1/5] Loading intents dataset ...")
with open("intents.json", "r", encoding="utf-8") as f:
    data = json.load(f)

intents = data["intents"]
print(f"      Loaded {len(intents)} intents.")


# =============================================================================
# STEP 2 — BUILD TRAINING CORPUS
# =============================================================================
# We flatten every (pattern, tag) pair into two parallel lists:
#   patterns_raw  – original sentences (kept for reference)
#   labels        – corresponding intent tags

patterns_raw: list[str] = []
labels:       list[str] = []

for intent in intents:
    for pattern in intent["patterns"]:
        patterns_raw.append(pattern)
        labels.append(intent["tag"])

print(f"\n[2/5] Built training corpus.")
print(f"      Total training samples : {len(patterns_raw)}")
print(f"      Unique intent classes  : {len(set(labels))}")
print(f"      Classes: {sorted(set(labels))}")

# Preprocess all patterns
patterns_clean = [preprocess(p) for p in patterns_raw]


# =============================================================================
# STEP 3 — TF-IDF FEATURE EXTRACTION
# =============================================================================
# HOW TF-IDF WORKS:
#
#   TF (Term Frequency):
#       How often a word appears in a specific document.
#       tf(t, d) = count(t in d) / total_words(d)
#
#   IDF (Inverse Document Frequency):
#       Penalises words that appear in EVERY document (like "the", "I", "and")
#       because they carry little discriminative information.
#       idf(t) = log( N / df(t) )   where N = total documents, df = # docs with t
#
#   TF-IDF = TF × IDF
#       High score → word is frequent IN this document but RARE across others.
#       This highlights the words that best characterise each training sentence.
#
# Parameters:
#   ngram_range=(1,2) → captures single words AND two-word phrases
#                       e.g. "feel stressed" is kept as one feature
#   min_df=1          → include all tokens (dataset is small)
#   sublinear_tf=True → apply log(1+tf) to dampen extremely frequent tokens

print("\n[3/5] Extracting TF-IDF features ...")
vectorizer = TfidfVectorizer(
    ngram_range=(1, 2),
    min_df=1,
    sublinear_tf=True
)

X = vectorizer.fit_transform(patterns_clean)

print(f"      Feature matrix shape   : {X.shape}")
print(f"      Vocabulary size        : {len(vectorizer.vocabulary_)}")


# =============================================================================
# STEP 4 — TRAIN LOGISTIC REGRESSION CLASSIFIER
# =============================================================================
# HOW LOGISTIC REGRESSION WORKS FOR INTENT CLASSIFICATION:
#
#   Logistic Regression learns a weight (coefficient) for every TF-IDF feature
#   for each class.  During prediction it computes a weighted sum of the input
#   features, passes it through the softmax function, and outputs a probability
#   distribution over all intent classes.
#
#   The class with the highest probability is the predicted intent.
#
#   Why Logistic Regression?
#     • Performs very well on high-dimensional, sparse text features (like TF-IDF)
#     • Fast to train and interpretable
#     • Naturally multi-class via the One-vs-Rest or Softmax strategy
#     • No need for large data volumes — ideal for a curated domain dataset
#
# Parameters:
#   max_iter=1000     → more iterations ensure convergence on text data
#   C=5.0             → moderate regularisation; prevents overfitting on small data
#   solver='lbfgs'    → efficient quasi-Newton optimiser for multi-class problems

print("\n[4/5] Training Logistic Regression classifier ...")
model = LogisticRegression(
    max_iter=1000,
    C=5.0,
    solver="lbfgs"
)
model.fit(X, labels)

# ----- Cross-validation to estimate generalisation accuracy -----
# 5-fold CV: dataset split into 5 parts; model trained 5 times, each time
# leaving out a different fold for validation.  Gives an unbiased accuracy estimate.
cv_scores = cross_val_score(model, X, labels, cv=5, scoring="accuracy")
print(f"\n      5-Fold Cross-Validation Accuracy:")
print(f"      Fold scores : {[round(s, 3) for s in cv_scores]}")
print(f"      Mean        : {np.mean(cv_scores):.3f}  ±  {np.std(cv_scores):.3f}")


# =============================================================================
# STEP 5 — SAVE MODEL AND VECTORISER WITH PICKLE
# =============================================================================
# pickle serialises Python objects to binary files.
# Loading from disk at runtime is ~1000x faster than retraining.

print("\n[5/5] Saving model and vectoriser ...")
with open("vectorizer.pkl", "wb") as f:
    pickle.dump(vectorizer, f)

with open("model.pkl", "wb") as f:
    pickle.dump(model, f)

print("      vectorizer.pkl  → saved")
print("      model.pkl       → saved")

print("\n" + "=" * 55)
print("  Training complete!  Run  python app.py  to start.")
print("=" * 55 + "\n")
