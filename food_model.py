import os

# Reduce TensorFlow/C++ verbose logs and disable oneDNN messages.
# These must be set before importing tensorflow.
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")

import sys
from pathlib import Path

# Try to silence absl pre-init warnings if available.
try:
    from absl import logging as _ab_logging
    _ab_logging.set_verbosity(_ab_logging.ERROR)
    if hasattr(_ab_logging, "_warn_preinit_stderr"):
        _ab_logging._warn_preinit_stderr(False)
except Exception:
    pass

import tensorflow as tf

import argparse

# CLI and env var handling:
# precedence: explicit CLI args > TRAIN_DIR/TEST_DIR env vars > DATASET_DIR env var > default
parser = argparse.ArgumentParser(description="Load image datasets (train/test).")
parser.add_argument("--dataset", help="Path to dataset root containing 'train' and 'test'")
parser.add_argument("--train", help="Path to train directory (overrides dataset root)")
parser.add_argument("--test", help="Path to test directory (overrides dataset root)")
args = parser.parse_args()

train_path = None
test_path = None

if args.train and args.test:
    train_path = Path(args.train)
    test_path = Path(args.test)
elif args.dataset:
    train_path = Path(args.dataset) / "train"
    test_path = Path(args.dataset) / "test"
else:
    # try env vars
    train_env = os.environ.get("TRAIN_DIR")
    test_env = os.environ.get("TEST_DIR")
    dataset_env = os.environ.get("DATASET_DIR")
    if train_env and test_env:
        train_path = Path(train_env)
        test_path = Path(test_env)
    elif dataset_env:
        train_path = Path(dataset_env) / "train"
        test_path = Path(dataset_env) / "test"
    else:
        # fallback to the original hard-coded path (backward-compat)
        default_root = Path(r"C:/Users/amias/dataset/dataset/Dataset")
        train_path = default_root / "train"
        test_path = default_root / "test"

missing = []
if not train_path.exists():
    missing.append(str(train_path))
if not test_path.exists():
    missing.append(str(test_path))

if missing:
    print("ERROR: Dataset paths not found.")
    print("Tried:")
    print(f"  train: {train_path}")
    print(f"  test:  {test_path}")
    print("\nOptions to fix:")
    print("- Provide both --train and --test on the command line:")
    print("  python food_model.py --train C:\\path\\to\\train --test C:\\path\\to\\test")
    print("- Or set the TRAIN_DIR and TEST_DIR environment variables.")
    print("- Or provide --dataset pointing to the root that contains 'train' and 'test'.")
    print("- Or set DATASET_DIR env var or update the default inside this script.")
    sys.exit(2)

train_ds = tf.keras.preprocessing.image_dataset_from_directory(
    str(train_path),
    image_size=(224, 224),
    batch_size=32,
)

test_ds = tf.keras.preprocessing.image_dataset_from_directory(
    str(test_path),
    image_size=(224, 224),
    batch_size=32,
)

print("Dataset loaded successfully")