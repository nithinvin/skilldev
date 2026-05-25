# Layer 7: ML, Deep Learning & LLMs

## What You'll Learn
- Machine Learning fundamentals (linear regression from scratch)
- Neural networks (forward pass, backprop, activation functions)
- Recommendation systems (collaborative filtering)
- LLM integration (prompt engineering, RAG, MCP)
- AI security (prompt injection, output validation)

## File Structure

```
mybookshelf/layer7/
├── linear_regression.py    ← ML from scratch: gradient descent, R², train/test
├── book_classifier.py      ← Neural network: genre classification (no libraries!)
├── recommender.py          ← Collaborative filtering: "users like you liked..."
├── llm_integration.py      ← LLMs: prompts, RAG, MCP server, prompt injection
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions
```

## Study Order

1. **linear_regression.py** — understand gradient descent, loss functions, R²
2. **book_classifier.py** — understand neurons, layers, backpropagation
3. **recommender.py** — understand similarity, collaborative filtering
4. **llm_integration.py** — understand prompts, RAG, MCP, security

## Key Concepts Map

```
Layer 7 Dependency Tree:

Linear Algebra (vectors, matrices, dot product)
    ↓
Linear Regression (y = wx + b, minimize loss)
    ↓
Neural Network (stacked linear transforms + activations)
    ↓
Deep Learning (many layers, CNNs, RNNs, Transformers)
    ↓
LLMs (Transformer architecture, trained on internet text)
    ↓
Applications (RAG, MCP, agents, fine-tuning)
```

## Math Prerequisites (Year 1 level)

| Concept | Where Used | Layer 7 File |
|---------|-----------|--------------|
| Dot product | Similarity, predictions | All files |
| Derivatives | Gradient computation | linear_regression.py |
| Chain rule | Backpropagation | book_classifier.py |
| Probability | Softmax, cross-entropy | book_classifier.py |
| Logarithms | Cross-entropy loss | book_classifier.py |

## Running the Files

```bash
# All files are standalone — no external packages needed!
cd mybookshelf/layer7

python3 linear_regression.py    # See gradient descent in action
python3 book_classifier.py      # Train a neural network
python3 recommender.py          # Get book recommendations
python3 llm_integration.py      # Learn about LLM integration
python3 checkpoint_quiz.py      # Test your knowledge
```

## Connection to Other Layers
- **Layer 2** → Database stores the training data (books, ratings)
- **Layer 3** → API serves ML model predictions
- **Layer 5** → Deploy ML models as microservices
- **Layer 6** → Prompt injection is a security concern
- **Layer 8** → Data analytics feeds ML models
