#!/usr/bin/env python3
"""
=============================================================================
Layer 7.2 — Book Genre Classifier (Neural Network Concepts)
=============================================================================
PURPOSE: Classify books into genres using a simple neural network.
We build from scratch to understand: neurons, layers, activation functions,
backpropagation, softmax, cross-entropy loss.

QUESTIONS:
  1. What is a neural network?
     Layers of "neurons" that transform input data step by step.
     Each neuron: output = activation(weights · inputs + bias)
     Stack layers → learn increasingly complex patterns.

  2. What is an activation function?
     Non-linear function applied after the linear transformation.
     Without it: stacking layers is useless (linear of linear = still linear).
     ReLU: max(0, x) — simple, works great, the default choice.
     Sigmoid: 1/(1+e^-x) — squashes to [0,1], used for probabilities.
     Softmax: normalizes outputs to probability distribution (for multi-class).

  3. What is backpropagation?
     Algorithm to compute gradients through the network.
     Forward: input → prediction.
     Backward: compare prediction to truth → propagate error backwards
     → compute how much each weight contributed to the error → update weights.

  4. What is overfitting?
     Model memorizes training data but fails on new data.
     Like memorizing exam answers without understanding the subject.
     Signs: training accuracy 99%, test accuracy 60%.
     Fixes: more data, dropout, regularization, early stopping.

RUN:
  python3 book_classifier.py
=============================================================================
"""

import random
import math


# =============================================================================
# PART 1: Data Preparation
# =============================================================================
def create_genre_dataset():
    """
    Create a book genre classification dataset.
    Features: [avg_word_length, num_pages, year, has_equations, has_code_snippets]
    Genres: programming, fiction, science, history

    Q: In real ML, you'd extract features from actual book text (NLP).
    Here we use simplified numeric features for learning.
    """
    random.seed(42)
    dataset = []

    # Programming books: long words, moderate pages, recent, has code
    for _ in range(50):
        features = [
            random.gauss(6.5, 0.5),     # avg word length (longer technical words)
            random.gauss(400, 100),      # pages
            random.gauss(2015, 5),       # year (recent)
            random.gauss(0.2, 0.1),      # has_equations (some)
            random.gauss(0.8, 0.1),      # has_code (yes!)
        ]
        dataset.append((features, "programming"))

    # Fiction: short words, varied pages, any year, no equations/code
    for _ in range(50):
        features = [
            random.gauss(4.5, 0.5),     # avg word length (common words)
            random.gauss(300, 100),      # pages
            random.gauss(1990, 20),      # year (any era)
            random.gauss(0.0, 0.05),    # no equations
            random.gauss(0.0, 0.05),    # no code
        ]
        dataset.append((features, "fiction"))

    # Science books: medium words, many pages, equations
    for _ in range(50):
        features = [
            random.gauss(7.0, 0.5),     # avg word length (scientific terms)
            random.gauss(500, 100),      # pages (thick books)
            random.gauss(2005, 10),      # year
            random.gauss(0.9, 0.1),     # lots of equations
            random.gauss(0.1, 0.1),     # some code
        ]
        dataset.append((features, "science"))

    # History books: medium words, many pages, older, no equations/code
    for _ in range(50):
        features = [
            random.gauss(5.5, 0.5),     # avg word length
            random.gauss(450, 100),      # pages
            random.gauss(1980, 15),      # year (older)
            random.gauss(0.0, 0.05),    # no equations
            random.gauss(0.0, 0.05),    # no code
        ]
        dataset.append((features, "history"))

    random.shuffle(dataset)
    return dataset


# =============================================================================
# PART 2: Neural Network From Scratch
# =============================================================================

def relu(x):
    """ReLU: max(0, x). Dead simple. The default activation function.
    Q: Why ReLU? It's fast, doesn't have vanishing gradient problem,
    and works well in practice. Most hidden layers use ReLU."""
    return max(0.0, x)


def relu_derivative(x):
    """Derivative of ReLU: 1 if x>0, else 0."""
    return 1.0 if x > 0 else 0.0


def softmax(logits):
    """
    Softmax: converts raw scores → probability distribution (sums to 1.0).
    Q: Why softmax for classification? We want probabilities:
    "70% programming, 20% science, 8% fiction, 2% history"
    """
    # Subtract max for numerical stability (prevent overflow)
    max_val = max(logits)
    exp_vals = [math.exp(x - max_val) for x in logits]
    total = sum(exp_vals)
    return [e / total for e in exp_vals]


def cross_entropy_loss(predicted_probs, true_class_idx):
    """
    Cross-entropy loss for classification.
    Q: Intuition: how surprised is the model by the true answer?
    If model says P(correct_class) = 0.9 → low loss (not surprised)
    If model says P(correct_class) = 0.01 → high loss (very surprised!)
    Formula: -log(P(correct_class))
    """
    prob = max(predicted_probs[true_class_idx], 1e-10)  # Avoid log(0)
    return -math.log(prob)


class SimpleNeuralNetwork:
    """
    2-layer neural network:
      Input (5 features) → Hidden Layer (8 neurons, ReLU) → Output (4 classes, Softmax)

    Q: Architecture choices:
    - 5 inputs: our 5 book features
    - 8 hidden neurons: enough to learn patterns, not so many to overfit
    - 4 outputs: one per genre (programming, fiction, science, history)
    """

    def __init__(self, input_size=5, hidden_size=8, output_size=4):
        # Q: Xavier initialization — scale by 1/sqrt(input_size)
        # Too large → exploding gradients. Too small → vanishing gradients.
        scale1 = 1.0 / math.sqrt(input_size)
        scale2 = 1.0 / math.sqrt(hidden_size)

        # Hidden layer weights and biases
        self.W1 = [[random.gauss(0, scale1) for _ in range(input_size)]
                    for _ in range(hidden_size)]
        self.b1 = [0.0] * hidden_size

        # Output layer weights and biases
        self.W2 = [[random.gauss(0, scale2) for _ in range(hidden_size)]
                    for _ in range(output_size)]
        self.b2 = [0.0] * output_size

    def forward(self, x):
        """
        Forward pass: input → hidden → output.
        Q: Each layer does: output = activation(W·x + b)
        """
        # Hidden layer: z1 = W1·x + b1, a1 = ReLU(z1)
        self.z1 = [sum(w * xi for w, xi in zip(self.W1[j], x)) + self.b1[j]
                   for j in range(len(self.W1))]
        self.a1 = [relu(z) for z in self.z1]

        # Output layer: z2 = W2·a1 + b2, output = softmax(z2)
        self.z2 = [sum(w * a for w, a in zip(self.W2[k], self.a1)) + self.b2[k]
                   for k in range(len(self.W2))]
        self.output = softmax(self.z2)

        return self.output

    def backward(self, x, true_class_idx, learning_rate=0.01):
        """
        Backpropagation: compute gradients and update weights.
        Q: The chain rule from calculus! Error flows backward through the network.

        Steps:
        1. Output error: how far off is the prediction?
        2. Hidden error: how much did each hidden neuron contribute to the output error?
        3. Update weights proportional to their contribution to the error.
        """
        # --- Output layer gradients ---
        # For softmax + cross-entropy, gradient simplifies to: predicted - one_hot(true)
        output_deltas = list(self.output)  # Copy predictions
        output_deltas[true_class_idx] -= 1.0  # Subtract 1 from true class
        # Q: This is the beauty of softmax + cross-entropy — gradient is just (pred - truth)!

        # --- Hidden layer gradients ---
        hidden_deltas = [0.0] * len(self.a1)
        for j in range(len(self.a1)):
            # How much did hidden neuron j contribute to output error?
            error_signal = sum(output_deltas[k] * self.W2[k][j]
                             for k in range(len(output_deltas)))
            hidden_deltas[j] = error_signal * relu_derivative(self.z1[j])

        # --- Update output layer (W2, b2) ---
        for k in range(len(self.W2)):
            for j in range(len(self.a1)):
                self.W2[k][j] -= learning_rate * output_deltas[k] * self.a1[j]
            self.b2[k] -= learning_rate * output_deltas[k]

        # --- Update hidden layer (W1, b1) ---
        for j in range(len(self.W1)):
            for i in range(len(x)):
                self.W1[j][i] -= learning_rate * hidden_deltas[j] * x[i]
            self.b1[j] -= learning_rate * hidden_deltas[j]

    def train(self, X, y, epochs=100, learning_rate=0.01, verbose=True):
        """Train the network for multiple epochs."""
        for epoch in range(epochs):
            total_loss = 0
            correct = 0

            for features, label_idx in zip(X, y):
                # Forward
                probs = self.forward(features)
                total_loss += cross_entropy_loss(probs, label_idx)

                # Accuracy
                if probs.index(max(probs)) == label_idx:
                    correct += 1

                # Backward
                self.backward(features, label_idx, learning_rate)

            if verbose and (epoch % 20 == 0 or epoch == epochs - 1):
                acc = correct / len(X) * 100
                avg_loss = total_loss / len(X)
                print(f"    Epoch {epoch:3d} | Loss: {avg_loss:.4f} | Accuracy: {acc:.1f}%")

    def predict(self, x):
        """Return class index with highest probability."""
        probs = self.forward(x)
        return probs.index(max(probs))


# =============================================================================
# PART 3: Normalize & Split
# =============================================================================
def normalize(X):
    """Normalize features to mean=0, std=1."""
    n_features = len(X[0])
    means = [sum(row[j] for row in X) / len(X) for j in range(n_features)]
    stds = [math.sqrt(sum((row[j] - means[j]) ** 2 for row in X) / len(X))
            for j in range(n_features)]
    stds = [s if s > 0 else 1.0 for s in stds]
    X_norm = [[(row[j] - means[j]) / stds[j] for j in range(n_features)] for row in X]
    return X_norm, means, stds


# =============================================================================
# MAIN
# =============================================================================
def main():
    print("\n" + "=" * 60)
    print("  NEURAL NETWORK: Book Genre Classifier")
    print("  From scratch — no libraries!")
    print("=" * 60)

    # Prepare data
    genres = ["programming", "fiction", "science", "history"]
    genre_to_idx = {g: i for i, g in enumerate(genres)}

    dataset = create_genre_dataset()
    X_raw = [features for features, _ in dataset]
    y = [genre_to_idx[label] for _, label in dataset]

    # Normalize
    X_norm, means, stds = normalize(X_raw)

    # Split 80/20
    split = int(len(X_norm) * 0.8)
    X_train, X_test = X_norm[:split], X_norm[split:]
    y_train, y_test = y[:split], y[split:]

    print(f"\n  Dataset: {len(dataset)} books, 4 genres")
    print(f"  Features: [avg_word_len, pages, year, has_equations, has_code]")
    print(f"  Train: {len(X_train)}, Test: {len(X_test)}")

    # Train
    print(f"\n  Training neural network (5→8→4)...")
    nn = SimpleNeuralNetwork(input_size=5, hidden_size=8, output_size=4)
    nn.train(X_train, y_train, epochs=100, learning_rate=0.05)

    # Evaluate on test set
    print(f"\n  Evaluating on test set...")
    correct = 0
    for features, label in zip(X_test, y_test):
        if nn.predict(features) == label:
            correct += 1
    test_acc = correct / len(X_test) * 100
    print(f"  Test Accuracy: {test_acc:.1f}%")

    # Confusion matrix (simple)
    print(f"\n  Confusion Matrix:")
    print(f"  {'':>12} {'Pred:':>6} {genres[0]:>12} {genres[1]:>8} {genres[2]:>8} {genres[3]:>8}")
    for true_idx, true_name in enumerate(genres):
        row = [0] * 4
        for features, label in zip(X_test, y_test):
            if label == true_idx:
                pred = nn.predict(features)
                row[pred] += 1
        print(f"  True: {true_name:>10} {row[0]:>12} {row[1]:>8} {row[2]:>8} {row[3]:>8}")

    # Classify a new book
    print(f"\n  --- Classify a new book ---")
    new_book = [7.2, 350, 2022, 0.1, 0.9]  # Looks like programming
    new_norm = [(new_book[j] - means[j]) / stds[j] for j in range(5)]
    probs = nn.forward(new_norm)
    print(f"  Features: avg_word=7.2, pages=350, year=2022, equations=0.1, code=0.9")
    print(f"  Probabilities:")
    for genre, prob in zip(genres, probs):
        bar = "█" * int(prob * 30)
        print(f"    {genre:>12}: {prob:.3f} {bar}")
    print(f"  Prediction: {genres[probs.index(max(probs))]}")

    print("""
  ─── KEY TAKEAWAYS ───
  • Neural network = layers of linear transforms + non-linear activations
  • Forward pass: input → prediction
  • Backward pass: error → gradients → weight updates
  • Softmax outputs probabilities (sum to 1.0)
  • Cross-entropy measures how wrong the predictions are
  • With PyTorch/TensorFlow: ~20 lines. But now you know what they DO.
    """)


if __name__ == "__main__":
    main()
