#!/usr/bin/env python3
"""
=============================================================================
Layer 7.1 — Machine Learning Fundamentals: Linear Regression from Scratch
=============================================================================
PURPOSE: Build linear regression from SCRATCH (no sklearn) to understand
what ML is actually doing under the hood. Then compare with sklearn.

QUESTIONS:
  1. What IS machine learning?
     Finding patterns in data by optimizing a mathematical function.
     Instead of writing rules (if rating > 4: recommend), let the
     algorithm LEARN rules from examples.

  2. What is linear regression?
     Find the best line (y = mx + b) that fits the data.
     "Best" = minimizes the total squared error between predictions and actual values.

  3. What is gradient descent?
     An optimization algorithm: start with random parameters, compute
     error, adjust parameters in the direction that reduces error.
     Repeat until error stops decreasing.
     Analogy: walking downhill in fog — take small steps in steepest direction.

  4. What are training and testing sets?
     Training: data the model learns from (80%).
     Testing: data the model has NEVER seen (20%). Used to check generalization.
     If model is great on training but bad on testing → OVERFITTING.

CONTEXT: We'll predict book RATINGS based on features (year, page count, etc.)

RUN:
  python3 linear_regression.py
=============================================================================
"""

import random
import math


# =============================================================================
# PART 1: Generate Book Data
# =============================================================================
def generate_book_data(n=100):
    """
    Generate synthetic book data.
    Q: In real ML, you'd load from a CSV/database.
    Here we generate data with a known relationship so we can verify our model.

    True relationship (hidden from model):
      rating = 0.002 * year + 0.001 * pages - 0.5 * is_sequel + noise
    """
    random.seed(42)  # Q: Seed = reproducible results. Same "random" numbers every run.
    data = []

    for _ in range(n):
        year = random.randint(1950, 2024)
        pages = random.randint(100, 800)
        is_sequel = random.choice([0, 1])
        # True relationship + random noise
        rating = (0.002 * year + 0.001 * pages - 0.5 * is_sequel
                  + random.gauss(0, 0.3))  # Noise: mean=0, std=0.3
        rating = max(1.0, min(5.0, rating))  # Clamp to [1, 5]
        data.append({"year": year, "pages": pages, "is_sequel": is_sequel, "rating": rating})

    return data


# =============================================================================
# PART 2: Linear Regression FROM SCRATCH
# =============================================================================
class LinearRegressionScratch:
    """
    Q: What is this class doing mathematically?
    Finding weights w₁, w₂, w₃ and bias b such that:
      predicted_rating = w₁*year + w₂*pages + w₃*is_sequel + b
    minimizes the Mean Squared Error (MSE).
    """

    def __init__(self, n_features):
        # Q: Why random initialization? If all weights start at 0,
        # gradient is the same for all → they all learn the same thing.
        self.weights = [random.gauss(0, 0.01) for _ in range(n_features)]
        self.bias = 0.0

    def predict(self, features):
        """
        Linear prediction: y = w₁x₁ + w₂x₂ + ... + b
        Q: This is just a dot product + bias!
        """
        return sum(w * x for w, x in zip(self.weights, features)) + self.bias

    def compute_loss(self, X, y):
        """
        Mean Squared Error (MSE):
          loss = (1/n) Σ (predicted - actual)²
        Q: Why squared? Penalizes large errors more than small ones.
        Q: Why mean? Makes loss independent of dataset size.
        """
        n = len(X)
        total_error = 0
        for features, actual in zip(X, y):
            predicted = self.predict(features)
            total_error += (predicted - actual) ** 2
        return total_error / n

    def fit(self, X, y, learning_rate=0.0001, epochs=1000, verbose=True):
        """
        Gradient Descent: iteratively adjust weights to minimize loss.

        Q: What is the gradient?
        The gradient tells us: "which direction increases the error?"
        We go in the OPPOSITE direction (downhill).

        For MSE, the gradient with respect to weight wⱼ is:
          ∂loss/∂wⱼ = (2/n) Σ (predicted - actual) * xⱼ

        Q: What is learning_rate?
        How big a step to take. Too large → overshoot. Too small → too slow.
        It's the most important hyperparameter.
        """
        n = len(X)

        for epoch in range(epochs):
            # === FORWARD PASS: make predictions ===
            predictions = [self.predict(features) for features in X]

            # === COMPUTE GRADIENTS ===
            # Q: These formulas come from calculus (derivative of MSE).
            # You'll learn the math in Year 2. For now: gradient = direction of steepest increase.
            weight_gradients = [0.0] * len(self.weights)
            bias_gradient = 0.0

            for i in range(n):
                error = predictions[i] - y[i]  # How far off is our prediction?
                for j in range(len(self.weights)):
                    weight_gradients[j] += (2 / n) * error * X[i][j]
                bias_gradient += (2 / n) * error

            # === UPDATE WEIGHTS (go opposite to gradient) ===
            for j in range(len(self.weights)):
                self.weights[j] -= learning_rate * weight_gradients[j]
            self.bias -= learning_rate * bias_gradient

            # Print progress
            if verbose and (epoch % 200 == 0 or epoch == epochs - 1):
                loss = self.compute_loss(X, y)
                print(f"    Epoch {epoch:4d} | Loss: {loss:.6f} | "
                      f"Weights: [{', '.join(f'{w:.4f}' for w in self.weights)}] | "
                      f"Bias: {self.bias:.4f}")

        return self


# =============================================================================
# PART 3: Feature Scaling (IMPORTANT!)
# =============================================================================
def normalize_features(X):
    """
    Q: Why normalize? Features have different scales:
      year: 1950-2024 (big numbers)
      pages: 100-800 (medium)
      is_sequel: 0-1 (tiny)

    Without normalization: year dominates, pages barely matters, is_sequel invisible.
    Gradient descent works much better with normalized features.

    Method: (x - mean) / std → all features centered at 0, scale ~1
    """
    n_features = len(X[0])
    means = [sum(row[j] for row in X) / len(X) for j in range(n_features)]
    stds = [
        math.sqrt(sum((row[j] - means[j]) ** 2 for row in X) / len(X))
        for j in range(n_features)
    ]

    # Avoid division by zero (constant features)
    stds = [s if s > 0 else 1.0 for s in stds]

    X_norm = [[(row[j] - means[j]) / stds[j] for j in range(n_features)] for row in X]
    return X_norm, means, stds


# =============================================================================
# PART 4: Train-Test Split
# =============================================================================
def train_test_split(X, y, test_ratio=0.2):
    """
    Q: Why split? If we test on training data, we're checking MEMORIZATION, not LEARNING.
    A model that memorizes all training examples but can't generalize = USELESS.
    """
    n = len(X)
    indices = list(range(n))
    random.shuffle(indices)
    split = int(n * (1 - test_ratio))

    X_train = [X[i] for i in indices[:split]]
    y_train = [y[i] for i in indices[:split]]
    X_test = [X[i] for i in indices[split:]]
    y_test = [y[i] for i in indices[split:]]

    return X_train, X_test, y_train, y_test


# =============================================================================
# PART 5: Evaluation Metrics
# =============================================================================
def r_squared(y_true, y_pred):
    """
    R² (coefficient of determination):
    - R²=1.0: perfect predictions
    - R²=0.0: model is no better than predicting the mean
    - R²<0:   model is WORSE than just predicting the mean (broken!)

    Q: Intuition: "What fraction of the variance does my model explain?"
    """
    mean_y = sum(y_true) / len(y_true)
    ss_res = sum((actual - pred) ** 2 for actual, pred in zip(y_true, y_pred))
    ss_tot = sum((actual - mean_y) ** 2 for actual in y_true)
    return 1 - (ss_res / ss_tot) if ss_tot != 0 else 0


def mean_absolute_error(y_true, y_pred):
    """Average absolute difference between predictions and actuals."""
    return sum(abs(a - p) for a, p in zip(y_true, y_pred)) / len(y_true)


# =============================================================================
# MAIN
# =============================================================================
def main():
    print("\n" + "=" * 60)
    print("  LINEAR REGRESSION FROM SCRATCH")
    print("  Predicting book ratings from features")
    print("=" * 60)

    # Generate data
    print("\n  [1] Generating book data...")
    data = generate_book_data(200)
    print(f"      Generated {len(data)} books")
    print(f"      Sample: {data[0]}")

    # Prepare features and target
    X = [[d["year"], d["pages"], d["is_sequel"]] for d in data]
    y = [d["rating"] for d in data]

    # Normalize
    print("\n  [2] Normalizing features...")
    X_norm, means, stds = normalize_features(X)
    print(f"      Means: year={means[0]:.0f}, pages={means[1]:.0f}, sequel={means[2]:.2f}")
    print(f"      Stds:  year={stds[0]:.0f}, pages={stds[1]:.0f}, sequel={stds[2]:.2f}")

    # Split
    print("\n  [3] Splitting into train (80%) and test (20%)...")
    X_train, X_test, y_train, y_test = train_test_split(X_norm, y)
    print(f"      Train: {len(X_train)} samples, Test: {len(X_test)} samples")

    # Train
    print("\n  [4] Training (gradient descent, 1000 epochs)...")
    model = LinearRegressionScratch(n_features=3)
    model.fit(X_train, y_train, learning_rate=0.01, epochs=1000)

    # Evaluate
    print("\n  [5] Evaluating on TEST set (never-seen data)...")
    test_predictions = [model.predict(features) for features in X_test]
    r2 = r_squared(y_test, test_predictions)
    mae = mean_absolute_error(y_test, test_predictions)
    print(f"      R² Score: {r2:.4f} (1.0 = perfect)")
    print(f"      Mean Absolute Error: {mae:.4f} stars")

    # Show some predictions
    print("\n  [6] Sample predictions vs actual:")
    print(f"      {'Actual':>8} {'Predicted':>10} {'Error':>8}")
    for i in range(min(10, len(X_test))):
        actual = y_test[i]
        pred = test_predictions[i]
        print(f"      {actual:8.2f} {pred:10.2f} {abs(actual-pred):8.2f}")

    # Interpret weights
    print("\n  [7] Learned weights (what the model discovered):")
    feature_names = ["year", "pages", "is_sequel"]
    for name, weight in zip(feature_names, model.weights):
        direction = "↑ higher rating" if weight > 0 else "↓ lower rating"
        print(f"      {name:>10}: {weight:+.4f} ({direction})")
    print(f"      {'bias':>10}: {model.bias:+.4f}")

    print("""
  ─── KEY TAKEAWAYS ───
  • Linear regression finds the best-fit hyperplane through data
  • Gradient descent iteratively minimizes the loss function
  • Feature normalization is CRITICAL for gradient descent
  • R² tells you how good your model is (0 = useless, 1 = perfect)
  • Train/test split prevents overfitting (cheating on the exam)
  • With sklearn: 3 lines of code. But now you know WHAT those 3 lines do!
    """)


if __name__ == "__main__":
    main()
