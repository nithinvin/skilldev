#!/usr/bin/env python3
"""
=============================================================================
Layer 7.3 — Book Recommender System
=============================================================================
PURPOSE: Build a recommendation engine using collaborative filtering.
"Users who liked this book also liked..."

QUESTIONS:
  1. What is collaborative filtering?
     Use the WISDOM OF THE CROWD to recommend items.
     If users A and B rated similar books similarly,
     recommend to A what B liked (and vice versa).

  2. What is the difference between content-based and collaborative filtering?
     Content-based: recommend books similar to what you already read
       (same author, genre, keywords). Needs item features.
     Collaborative: recommend what similar USERS liked.
       Doesn't need to know anything about the books themselves!

  3. What is cosine similarity?
     Measures angle between two vectors (user ratings as vectors).
     cos(A,B) = (A·B) / (|A|×|B|)
     1.0 = identical taste, 0.0 = no overlap, -1.0 = opposite taste.

  4. What is the cold-start problem?
     New user: no ratings → can't compute similarity → can't recommend.
     New item: no one rated it → never gets recommended.
     Fixes: ask for initial ratings, use content-based for new items,
     use popularity for new users.

RUN:
  python3 recommender.py
=============================================================================
"""

import math
import random


# =============================================================================
# PART 1: Data (User-Book Rating Matrix)
# =============================================================================

# Books in our collection
BOOKS = {
    1: "Clean Code",
    2: "The Pragmatic Programmer",
    3: "DDIA (Designing Data-Intensive Apps)",
    4: "The Great Gatsby",
    5: "1984",
    6: "Pride and Prejudice",
    7: "A Brief History of Time",
    8: "Sapiens",
    9: "Deep Learning (Goodfellow)",
    10: "Python Crash Course",
}

# User ratings: user_id → {book_id: rating (1-5)}
# None means user hasn't rated that book (we want to predict these!)
RATINGS = {
    "nithin":   {1: 5, 2: 5, 3: 5, 4: 2, 5: 3, 6: None, 7: 4, 8: 3, 9: 5, 10: 4},
    "alice":    {1: 4, 2: 4, 3: 4, 4: 5, 5: 5, 6: 5, 7: 3, 8: 4, 9: None, 10: 3},
    "bob":      {1: 5, 2: 5, 3: 4, 4: 1, 5: 2, 6: 1, 7: 5, 8: 3, 9: 4, 10: 5},
    "carol":    {1: 2, 2: 1, 3: None, 4: 5, 5: 5, 6: 5, 7: 2, 8: 5, 9: 1, 10: 1},
    "dave":     {1: 5, 2: 4, 3: 5, 4: 3, 5: 3, 6: 2, 7: 4, 8: None, 9: 5, 10: 5},
    "eve":      {1: 3, 2: 3, 3: 2, 4: 5, 5: 4, 6: 5, 7: 3, 8: 5, 9: None, 10: 2},
    "frank":    {1: None, 2: 5, 3: 4, 4: 2, 5: 3, 6: 1, 7: 5, 8: 4, 9: 4, 10: 4},
}


# =============================================================================
# PART 2: Cosine Similarity
# =============================================================================
def cosine_similarity(user_a_ratings, user_b_ratings):
    """
    Compute cosine similarity between two users.
    Only consider books BOTH users have rated.

    Q: Why cosine and not Euclidean distance?
    Cosine is scale-invariant: a user who rates everything 1-3
    and a user who rates 3-5 can still be "similar" if they agree
    on relative preferences.
    """
    # Find common rated books
    common_books = []
    for book_id in user_a_ratings:
        if (user_a_ratings[book_id] is not None and
            book_id in user_b_ratings and
            user_b_ratings[book_id] is not None):
            common_books.append(book_id)

    if len(common_books) < 2:
        return 0.0  # Not enough overlap to judge similarity

    # Compute cosine similarity
    a_vec = [user_a_ratings[b] for b in common_books]
    b_vec = [user_b_ratings[b] for b in common_books]

    dot_product = sum(a * b for a, b in zip(a_vec, b_vec))
    mag_a = math.sqrt(sum(a ** 2 for a in a_vec))
    mag_b = math.sqrt(sum(b ** 2 for b in b_vec))

    if mag_a == 0 or mag_b == 0:
        return 0.0

    return dot_product / (mag_a * mag_b)


# =============================================================================
# PART 3: Predict Ratings (Collaborative Filtering)
# =============================================================================
def predict_rating(target_user, book_id, all_ratings, k=3):
    """
    Predict what rating target_user would give to book_id.
    Method: weighted average of ratings from the K most similar users.

    Q: Why weighted? More similar users should have more influence.
    If bob (similarity=0.95) rated it 5 and carol (similarity=0.3) rated it 2,
    the prediction should be closer to 5 than to 2.
    """
    target_ratings = all_ratings[target_user]

    # Compute similarity with all other users
    similarities = []
    for other_user, other_ratings in all_ratings.items():
        if other_user == target_user:
            continue
        if other_ratings.get(book_id) is None:
            continue  # Other user hasn't rated this book either

        sim = cosine_similarity(target_ratings, other_ratings)
        if sim > 0:  # Only consider positively similar users
            similarities.append((other_user, sim, other_ratings[book_id]))

    if not similarities:
        return None  # Can't predict

    # Sort by similarity (highest first) and take top K
    similarities.sort(key=lambda x: x[1], reverse=True)
    top_k = similarities[:k]

    # Weighted average
    # Q: Formula: predicted = Σ(similarity × rating) / Σ(similarity)
    numerator = sum(sim * rating for _, sim, rating in top_k)
    denominator = sum(sim for _, sim, _ in top_k)

    return numerator / denominator if denominator > 0 else None


# =============================================================================
# PART 4: Generate Recommendations
# =============================================================================
def get_recommendations(target_user, all_ratings, n=5):
    """
    Recommend top N books the user hasn't rated yet.
    Strategy: predict rating for all unrated books, return highest predicted.
    """
    target_ratings = all_ratings[target_user]
    predictions = []

    for book_id in BOOKS:
        if target_ratings.get(book_id) is None:
            # User hasn't rated this book → predict!
            predicted = predict_rating(target_user, book_id, all_ratings)
            if predicted is not None:
                predictions.append((book_id, predicted))

    # Sort by predicted rating (highest first)
    predictions.sort(key=lambda x: x[1], reverse=True)
    return predictions[:n]


# =============================================================================
# PART 5: Evaluation (Leave-One-Out)
# =============================================================================
def evaluate_recommender(all_ratings):
    """
    Evaluate accuracy by "hiding" known ratings and seeing if we predict them.
    Q: This is like a teacher hiding the answer and checking if the student
    can figure it out. If predictions are close to actual → good model.
    """
    errors = []

    for user, ratings in all_ratings.items():
        for book_id, actual_rating in ratings.items():
            if actual_rating is None:
                continue

            # Temporarily hide this rating
            original = ratings[book_id]
            ratings[book_id] = None

            # Try to predict it
            predicted = predict_rating(user, book_id, all_ratings)

            # Restore
            ratings[book_id] = original

            if predicted is not None:
                errors.append(abs(predicted - actual_rating))

    if errors:
        mae = sum(errors) / len(errors)
        rmse = math.sqrt(sum(e ** 2 for e in errors) / len(errors))
        return mae, rmse, len(errors)
    return None, None, 0


# =============================================================================
# MAIN
# =============================================================================
def main():
    print("\n" + "=" * 60)
    print("  BOOK RECOMMENDER SYSTEM")
    print("  Collaborative Filtering from scratch")
    print("=" * 60)

    # Show the rating matrix
    print("\n  Rating Matrix (1-5 stars, '-' = not rated):")
    print(f"  {'User':<8}", end="")
    for book_id in range(1, 11):
        print(f" B{book_id:<2}", end="")
    print()
    print("  " + "-" * 45)
    for user, ratings in RATINGS.items():
        print(f"  {user:<8}", end="")
        for book_id in range(1, 11):
            r = ratings.get(book_id)
            print(f" {r if r is not None else '-':<3}", end="")
        print()

    # User similarities
    print("\n  User Similarities (cosine):")
    target = "nithin"
    print(f"  How similar is each user to '{target}'?")
    for other_user in RATINGS:
        if other_user != target:
            sim = cosine_similarity(RATINGS[target], RATINGS[other_user])
            bar = "█" * int(sim * 20) if sim > 0 else ""
            print(f"    {other_user:<8}: {sim:.3f} {bar}")

    # Recommendations for Nithin
    print(f"\n  Recommendations for '{target}':")
    recs = get_recommendations(target, RATINGS)
    for book_id, predicted_rating in recs:
        print(f"    '{BOOKS[book_id]}' — predicted rating: {predicted_rating:.2f}★")

    # Predictions for all missing ratings
    print(f"\n  All predicted ratings for '{target}':")
    for book_id in BOOKS:
        if RATINGS[target].get(book_id) is None:
            pred = predict_rating(target, book_id, RATINGS)
            status = f"{pred:.2f}★" if pred else "can't predict"
            print(f"    Book {book_id} '{BOOKS[book_id]}': {status}")

    # Evaluate
    print(f"\n  Model Evaluation (leave-one-out):")
    mae, rmse, n_tests = evaluate_recommender(RATINGS)
    if mae:
        print(f"    Mean Absolute Error: {mae:.3f} stars")
        print(f"    RMSE: {rmse:.3f} stars")
        print(f"    Tested on: {n_tests} ratings")
        print(f"    → On average, predictions are off by {mae:.2f} stars")

    print("""
  ─── KEY TAKEAWAYS ───
  • Collaborative filtering: "users like you liked X"
  • Cosine similarity measures how aligned two users' tastes are
  • Predict rating = weighted average of similar users' ratings
  • Cold-start problem: new users/items have no data to work with
  • Real systems (Netflix, Spotify) combine:
    - Collaborative filtering (user behavior)
    - Content-based (item features)
    - Deep learning (embeddings)
    - Business rules (diversity, freshness)
    """)


if __name__ == "__main__":
    main()
