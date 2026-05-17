# Layer 7: Machine Learning, Deep Learning & LLMs

> **Goal**: Understand ML from first principles. Add intelligent features to MyBookShelf. Build an MCP server.
> **Pre-req**: Layer 6 complete — secure, deployed, production-ready app.
> **Why?** ML is transforming every domain. As a CSE student, you need to understand what's under the hood — not just call APIs. Your DSA + linear algebra + Python foundation makes this approachable.

---

## Level 7.1 — What Is Machine Learning? (First Principles)

### Questions to Answer First
1. What is the difference between traditional programming and machine learning?
2. What is a model? What does "training" mean?
3. What is supervised vs unsupervised vs reinforcement learning?
4. What is overfitting? Underfitting? How do you detect each?
5. What is a loss function? What does gradient descent do?

### Theory (Concise)
```
Traditional: Input + Rules → Output
ML:          Input + Output → Rules (the model learns the rules)

Supervised:   Labeled data → Learn mapping (classification, regression)
Unsupervised: Unlabeled data → Find structure (clustering, dimensionality reduction)
Reinforcement: Environment + reward signal → Learn policy (games, robotics)

Training loop:
  1. Forward pass: prediction = model(input)
  2. Compute loss: error = loss_fn(prediction, actual)
  3. Backward pass: gradients = d(loss)/d(weights)
  4. Update weights: weights -= learning_rate * gradients
  5. Repeat
```

---

## Level 7.2 — ML from Scratch (No Libraries)

### Questions to Answer First
1. What is linear regression? Can you derive the math?
2. What is gradient descent? Why not just solve the equation directly?
3. What is a learning rate? What happens if it's too high or too low?

### Hands-On: Linear Regression from Scratch
```python
# file: mybookshelf/ml/linear_regression.py
import numpy as np
import matplotlib.pyplot as plt

# Generate data: y = 3x + 2 + noise
np.random.seed(42)
X = np.random.uniform(0, 10, 100)
y = 3 * X + 2 + np.random.normal(0, 2, 100)

# Q: We KNOW the true relationship is y = 3x + 2. Can the model learn this?

# Initialize parameters randomly
w = np.random.randn()  # weight (slope)
b = np.random.randn()  # bias (intercept)
lr = 0.01               # learning rate

# Training loop
losses = []
for epoch in range(100):
    # Forward pass
    y_pred = w * X + b

    # Compute loss (Mean Squared Error)
    loss = np.mean((y_pred - y) ** 2)
    losses.append(loss)

    # Compute gradients (calculus!)
    dw = (2 / len(X)) * np.sum((y_pred - y) * X)  # d(loss)/d(w)
    db = (2 / len(X)) * np.sum(y_pred - y)          # d(loss)/d(b)

    # Update parameters
    w -= lr * dw
    b -= lr * db

    if epoch % 10 == 0:
        print(f"Epoch {epoch}: loss={loss:.4f}, w={w:.4f}, b={b:.4f}")

print(f"\nLearned: y = {w:.2f}x + {b:.2f}")
print(f"Actual:  y = 3.00x + 2.00")

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.scatter(X, y, alpha=0.5, label='Data')
ax1.plot(X, w * X + b, 'r-', label=f'Prediction: y={w:.2f}x+{b:.2f}')
ax1.legend()
ax1.set_title('Linear Regression')

ax2.plot(losses)
ax2.set_title('Loss over epochs')
ax2.set_xlabel('Epoch')
ax2.set_ylabel('MSE Loss')

plt.tight_layout()
plt.savefig('linear_regression.png')
plt.show()
```

### Break It
- Set learning rate to 10 — what happens? (exploding gradients)
- Set learning rate to 0.0001 — what happens? (too slow)
- Add more noise — does the model still converge?
- Use only 5 data points — does it overfit?

---

## Level 7.3 — Scikit-Learn: Classification & Real Datasets

### Questions to Answer First
1. What is classification vs regression?
2. What is a decision tree? How does it make decisions?
3. What is train/test split? Why can't you test on training data?
4. What are precision, recall, F1-score?

### Hands-On: Book Rating Prediction
```python
# file: mybookshelf/ml/book_classifier.py
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
from sklearn.feature_extraction.text import TfidfVectorizer

# Create a dataset (in real life, this comes from your DB)
data = pd.DataFrame({
    'title': ['Code', 'Clean Code', 'CLRS Algorithms', 'Python Crash Course',
              'Deep Learning', 'JavaScript Good Parts', 'Design Patterns',
              'The Pragmatic Programmer', 'SICP', 'Art of Computer Programming'],
    'author': ['Petzold', 'Martin', 'Cormen', 'Matthes', 'Goodfellow',
               'Crockford', 'GoF', 'Hunt', 'Abelson', 'Knuth'],
    'year': [1999, 2008, 2009, 2015, 2016, 2008, 1994, 1999, 1996, 1968],
    'rating': [5, 3, 4, 3, 4, 3, 4, 5, 5, 5]  # target
})

# Feature engineering
# Q: Why convert text to numbers? ML models need numerical input
vectorizer = TfidfVectorizer(max_features=50)
title_features = vectorizer.fit_transform(data['title']).toarray()

X = pd.DataFrame(title_features)
X['year'] = data['year']
y = (data['rating'] >= 4).astype(int)  # Binary: good (1) vs mediocre (0)

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Train
model = RandomForestClassifier(n_estimators=10, random_state=42)
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
print(classification_report(y_test, y_pred, target_names=['Mediocre', 'Good']))

# Q: With only 10 data points, can this model really learn anything useful?
# Q: What would you need to make this actually work?
```

---

## Level 7.4 — Neural Networks & Deep Learning

### Questions to Answer First
1. What is a neural network? How is it different from linear regression?
2. What is a neuron? An activation function? Why non-linearity?
3. What is backpropagation? (hint: chain rule from calculus)
4. What is PyTorch? How is it different from NumPy?
5. What is a GPU? Why is it faster than a CPU for ML? (hint: parallel matrix multiplications)

### Hands-On: Neural Network from Scratch
```python
# file: mybookshelf/ml/neural_net_scratch.py
import numpy as np

# XOR problem — can't be solved with linear regression!
X = np.array([[0,0], [0,1], [1,0], [1,1]])
y = np.array([[0], [1], [1], [0]])

# Q: Why can't a single linear layer solve XOR? (Draw it!)

np.random.seed(42)

# 2 inputs → 4 hidden → 1 output
W1 = np.random.randn(2, 4) * 0.5
b1 = np.zeros((1, 4))
W2 = np.random.randn(4, 1) * 0.5
b2 = np.zeros((1, 1))

def sigmoid(x):
    return 1 / (1 + np.exp(-np.clip(x, -500, 500)))

def sigmoid_derivative(x):
    return x * (1 - x)

lr = 1.0

for epoch in range(10000):
    # Forward pass
    hidden = sigmoid(X @ W1 + b1)        # (4,2) @ (2,4) = (4,4)
    output = sigmoid(hidden @ W2 + b2)    # (4,4) @ (4,1) = (4,1)

    # Loss
    loss = np.mean((y - output) ** 2)

    # Backward pass (backpropagation — chain rule!)
    d_output = (output - y) * sigmoid_derivative(output)
    d_hidden = d_output @ W2.T * sigmoid_derivative(hidden)

    # Update weights
    W2 -= lr * hidden.T @ d_output
    b2 -= lr * np.sum(d_output, axis=0, keepdims=True)
    W1 -= lr * X.T @ d_hidden
    b1 -= lr * np.sum(d_hidden, axis=0, keepdims=True)

    if epoch % 1000 == 0:
        print(f"Epoch {epoch}: loss={loss:.6f}")

print("\nPredictions:")
for i in range(4):
    print(f"  {X[i]} → {output[i][0]:.4f} (expected {y[i][0]})")
```

---

## Level 7.5 — PyTorch Basics

### Hands-On: Same Neural Net in PyTorch
```python
# file: mybookshelf/ml/pytorch_intro.py
import torch
import torch.nn as nn

# XOR data
X = torch.tensor([[0,0], [0,1], [1,0], [1,1]], dtype=torch.float32)
y = torch.tensor([[0], [1], [1], [0]], dtype=torch.float32)

class XORNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.layer1 = nn.Linear(2, 4)
        self.layer2 = nn.Linear(4, 1)
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        x = self.sigmoid(self.layer1(x))
        x = self.sigmoid(self.layer2(x))
        return x

model = XORNet()
optimizer = torch.optim.SGD(model.parameters(), lr=1.0)
loss_fn = nn.MSELoss()

# Training loop — Q: Compare this to your from-scratch version
for epoch in range(10000):
    output = model(X)
    loss = loss_fn(output, y)

    optimizer.zero_grad()   # Q: Why zero gradients?
    loss.backward()         # Automatic backpropagation!
    optimizer.step()        # Update weights

    if epoch % 1000 == 0:
        print(f"Epoch {epoch}: loss={loss.item():.6f}")

print("\nPredictions:")
with torch.no_grad():
    predictions = model(X)
    for i in range(4):
        print(f"  {X[i].tolist()} → {predictions[i].item():.4f} (expected {y[i].item()})")
```

---

## Level 7.6 — LLMs: How They Work

### Questions to Answer First
1. What is a language model? What does it predict?
2. What is a transformer? What is "attention"?
3. What is tokenization? Why do LLMs work with tokens, not characters?
4. What is the difference between GPT (decoder-only) and BERT (encoder-only)?
5. What is fine-tuning? What is prompting? RAG?
6. What is temperature? Top-k? Top-p? (sampling strategies)

### Theory (Concise)
```
Language Model: Given "The cat sat on the" → predicts "mat" (most likely next token)

Transformer architecture (simplified):
  Input → Tokenize → Embedding → [Attention + FFN] × N layers → Output logits → Token

Attention: "Which other tokens should I pay attention to?"
  "The bank was on the river" → "bank" attends to "river" → means "riverbank"
  "The bank was on the corner" → "bank" attends to "corner" → means "financial bank"

Key insight: Attention lets the model understand CONTEXT.
```

### Hands-On: Use a Local LLM
```bash
# Install Ollama (local LLM runner)
curl -fsSL https://ollama.com/install.sh | sh

# Pull a small model
ollama pull llama3.2:1b   # ~1GB, runs on CPU

# Chat
ollama run llama3.2:1b "What is a B-tree? Explain like I'm a CS student."
```

### Hands-On: LLM API in Python
```python
# file: mybookshelf/ml/llm_demo.py
import requests

def ask_ollama(prompt, model="llama3.2:1b"):
    """Query local Ollama API."""
    response = requests.post(
        "http://localhost:11434/api/generate",
        json={"model": model, "prompt": prompt, "stream": False}
    )
    return response.json()["response"]

# Book recommendation
prompt = """Based on these books I like:
- "Code" by Charles Petzold (understanding computers from first principles)
- "SICP" by Abelson & Sussman (computational thinking)
- "The C Programming Language" by K&R (systems programming)

Recommend 3 similar books with one sentence about each."""

print(ask_ollama(prompt))
```

---

## Level 7.7 — Add ML Features to MyBookShelf

### Feature 1: Smart Book Recommendations
```python
# file: mybookshelf/ml/recommender.py
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

class BookRecommender:
    def __init__(self):
        self.vectorizer = TfidfVectorizer(stop_words='english')
        self.books = []
        self.tfidf_matrix = None

    def fit(self, books):
        """Build recommendation model from book data."""
        self.books = books
        # Combine title + author for richer features
        texts = [f"{b['title']} {b['author']}" for b in books]
        self.tfidf_matrix = self.vectorizer.fit_transform(texts)

    def recommend(self, book_id, n=3):
        """Find n most similar books to the given book."""
        idx = next(i for i, b in enumerate(self.books) if b['id'] == book_id)
        similarities = cosine_similarity(self.tfidf_matrix[idx], self.tfidf_matrix).flatten()
        # Get top n+1 (excluding the book itself)
        similar_indices = similarities.argsort()[::-1][1:n+1]
        return [(self.books[i], similarities[i]) for i in similar_indices]

# API endpoint
@app.route('/api/books/<int:book_id>/recommendations')
def get_recommendations(book_id):
    books = get_all_books()
    recommender = BookRecommender()
    recommender.fit(books)
    recs = recommender.recommend(book_id, n=3)
    return jsonify([{"book": r[0], "similarity": round(r[1], 3)} for r in recs])
```

### Feature 2: LLM-Powered Book Search
```python
# file: mybookshelf/ml/llm_search.py
def semantic_search(query, books):
    """Use LLM to find relevant books from natural language queries."""
    book_list = "\n".join([f"- {b['title']} by {b['author']} ({b['year']})" for b in books])

    prompt = f"""Given this book collection:
{book_list}

User query: "{query}"

Return the titles of the most relevant books as a JSON array. Only return the JSON, nothing else.
Example: ["Book Title 1", "Book Title 2"]"""

    response = ask_ollama(prompt)
    # Parse and match to actual books
    # (In production, use embeddings for proper semantic search)
    return response
```

---

## Level 7.8 — MCP Server: Model Context Protocol

### Questions to Answer First
1. What is MCP (Model Context Protocol)?
2. How does it let LLMs interact with external tools/data?
3. What is the difference between a tool, a resource, and a prompt in MCP?

### Hands-On: Build an MCP Server for MyBookShelf
```python
# file: mybookshelf/mcp_server.py
"""MCP Server that exposes MyBookShelf data to LLMs."""
from mcp.server import Server
from mcp.types import Tool, TextContent
import json
import psycopg2
from psycopg2.extras import RealDictCursor

app = Server("mybookshelf-mcp")

DATABASE_URL = "postgresql://bookshelf_user:bookshelf_pass@localhost/mybookshelf"

def get_db():
    return psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)

@app.list_tools()
async def list_tools():
    return [
        Tool(
            name="search_books",
            description="Search for books in MyBookShelf by title or author",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "Search query"}
                },
                "required": ["query"]
            }
        ),
        Tool(
            name="add_book",
            description="Add a new book to MyBookShelf",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {"type": "string"},
                    "author": {"type": "string"},
                    "year": {"type": "integer"},
                    "rating": {"type": "integer", "minimum": 1, "maximum": 5}
                },
                "required": ["title", "author", "year", "rating"]
            }
        ),
        Tool(
            name="get_book_stats",
            description="Get statistics about the book collection",
            inputSchema={"type": "object", "properties": {}}
        ),
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict):
    conn = get_db()
    cur = conn.cursor()

    if name == "search_books":
        cur.execute(
            "SELECT id, title, author, year, rating FROM books WHERE title ILIKE %s OR author ILIKE %s",
            (f"%{arguments['query']}%", f"%{arguments['query']}%")
        )
        books = [dict(b) for b in cur.fetchall()]
        return [TextContent(type="text", text=json.dumps(books, indent=2, default=str))]

    elif name == "add_book":
        cur.execute(
            "INSERT INTO books (title, author, year, rating) VALUES (%s, %s, %s, %s) RETURNING *",
            (arguments['title'], arguments['author'], arguments['year'], arguments['rating'])
        )
        book = dict(cur.fetchone())
        conn.commit()
        return [TextContent(type="text", text=f"Added: {json.dumps(book, default=str)}")]

    elif name == "get_book_stats":
        cur.execute("SELECT COUNT(*) as total, AVG(rating) as avg_rating, MIN(year) as oldest, MAX(year) as newest FROM books")
        stats = dict(cur.fetchone())
        return [TextContent(type="text", text=json.dumps(stats, default=str))]

    cur.close()
    conn.close()

if __name__ == "__main__":
    import asyncio
    from mcp.server.stdio import stdio_server

    async def main():
        async with stdio_server() as (read, write):
            await app.run(read, write)

    asyncio.run(main())
```

```bash
pip install mcp
# Run: python3 mcp_server.py
# Configure in your IDE/LLM client to connect via stdio
```

---

## Checkpoint Questions (Answer Before Moving to Layer 8)

1. What is gradient descent? Draw the loss landscape and show how weights update.
2. What is overfitting? How do train/test split, regularization, and cross-validation help?
3. What is a neural network? Why does it need non-linear activation functions?
4. What is attention in transformers? Why is it the key innovation?
5. What is the difference between fine-tuning and RAG?
6. Build a simple recommender for MyBookShelf and explain how cosine similarity works.
7. What is MCP? How does it enable LLMs to interact with your data?

---

**Previous**: [Layer 6 — Cryptography & Security](layer6-security-crypto.md)
**Next**: [Layer 8 — Data Analytics](layer8-data-analytics.md)
