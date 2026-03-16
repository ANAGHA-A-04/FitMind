import os
import argparse
from pathlib import Path
import datetime

# Reduce TensorFlow logs
os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
os.environ.setdefault("TF_ENABLE_ONEDNN_OPTS", "0")

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers


def build_datasets(train_dir, test_dir, image_size=(224, 224), batch_size=32):

    train_ds = tf.keras.preprocessing.image_dataset_from_directory(
        str(train_dir),
        image_size=image_size,
        batch_size=batch_size
    )

    test_ds = tf.keras.preprocessing.image_dataset_from_directory(
        str(test_dir),
        image_size=image_size,
        batch_size=batch_size
    )

    # Save class names before modifying dataset
    class_names = train_ds.class_names

    AUTOTUNE = tf.data.AUTOTUNE

    train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
    test_ds = test_ds.cache().prefetch(buffer_size=AUTOTUNE)

    return train_ds, test_ds, class_names


def build_model(num_classes, image_size=(224, 224)):

    inputs = keras.Input(shape=(*image_size, 3))

    x = layers.Rescaling(1.0 / 255)(inputs)

    # Data augmentation
    x = layers.RandomFlip("horizontal")(x)
    x = layers.RandomRotation(0.1)(x)
    x = layers.RandomZoom(0.15)(x)

    # Block 1
    x = layers.Conv2D(32, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(32, (3, 3), activation="relu")(x)
    x = layers.MaxPooling2D()(x)

    # Block 2
    x = layers.Conv2D(64, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(64, (3, 3), activation="relu")(x)
    x = layers.MaxPooling2D()(x)

    # Block 3
    x = layers.Conv2D(128, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.Conv2D(128, (3, 3), activation="relu")(x)
    x = layers.MaxPooling2D()(x)

    # Block 4
    x = layers.Conv2D(256, (3, 3), padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.MaxPooling2D()(x)

    x = layers.GlobalAveragePooling2D()(x)

    x = layers.Dense(256, activation="relu")(x)
    x = layers.Dropout(0.5)(x)

    outputs = layers.Dense(num_classes, activation="softmax")(x)

    model = keras.Model(inputs, outputs)

    return model


def main():

    parser = argparse.ArgumentParser()

    parser.add_argument("--dataset", help="Dataset root containing train/ and test/")
    parser.add_argument("--train", help="Train directory path")
    parser.add_argument("--test", help="Test directory path")

    parser.add_argument("--epochs", type=int, default=5)
    parser.add_argument("--batch-size", type=int, default=32)

    parser.add_argument("--image-size", type=int, nargs=2, default=[224, 224])
    parser.add_argument("--output", default="models")

    args = parser.parse_args()

    # Resolve dataset paths
    if args.train and args.test:
        train_dir = Path(args.train)
        test_dir = Path(args.test)

    elif args.dataset:
        root = Path(args.dataset)
        train_dir = root / "train"
        test_dir = root / "test"

    else:
        raise SystemExit("Provide --dataset or --train and --test paths")

    if not train_dir.exists() or not test_dir.exists():
        raise SystemExit(f"Dataset paths not found: {train_dir} , {test_dir}")

    print("Found dataset:")
    print(f"train: {train_dir}")
    print(f"test:  {test_dir}")

    train_ds, test_ds, class_names = build_datasets(
        train_dir,
        test_dir,
        tuple(args.image_size),
        args.batch_size
    )

    num_classes = len(class_names)

    print(f"Classes: {num_classes} -> {class_names}")

    model = build_model(num_classes, tuple(args.image_size))

    model.compile(
        optimizer=keras.optimizers.Adam(),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"]
    )

    log_dir = Path(args.output) / datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    log_dir.mkdir(parents=True, exist_ok=True)

    callbacks = [

        keras.callbacks.ModelCheckpoint(
            str(log_dir / "best_model.keras"),
            save_best_only=True,
            monitor="val_accuracy"
        ),

        keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=5,
            restore_best_weights=True
        ),

        keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.3,
            patience=3,
            min_lr=1e-6
        ),

        keras.callbacks.TensorBoard(
            log_dir=str(log_dir / "tb_logs")
        )
    ]

    model.fit(
        train_ds,
        validation_data=test_ds,
        epochs=args.epochs,
        callbacks=callbacks
    )

    # Save final model
    final_path = log_dir / "final_model.keras"
    model.save(final_path)

    # Save class names
    with open(log_dir / "class_names.txt", "w", encoding="utf-8") as f:
        for c in class_names:
            f.write(c + "\n")

    print(f"Model saved to: {log_dir}")


if __name__ == "__main__":
    main()