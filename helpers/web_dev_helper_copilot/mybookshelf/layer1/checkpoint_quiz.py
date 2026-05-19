#!/usr/bin/env python3
"""
=============================================================================
Layer 1 Checkpoint Quiz — HTML, CSS, JavaScript
=============================================================================
Score 12/15 to proceed to Layer 2.

Run: python3 checkpoint_quiz.py
=============================================================================
"""

import random

QUESTIONS = [
    {
        "q": "What does 'semantic HTML' mean?",
        "options": [
            "Using <div> for everything with class names",
            "Using elements that describe their meaning (nav, article, header)",
            "Adding comments to explain the HTML",
            "Using HTML5 instead of HTML4"
        ],
        "answer": 1,
        "explanation": "Semantic elements convey MEANING to browsers and screen readers. "
                       "<nav> says 'this is navigation', while <div class='nav'> is meaningless to machines."
    },
    {
        "q": "What is the CSS specificity of '#main .title h1'?",
        "options": [
            "0, 0, 3 (three elements)",
            "0, 1, 1, 1 (one ID, one class, one element)",
            "1, 1, 1 (one of each)",
            "0, 2, 1 (two classes, one element)"
        ],
        "answer": 1,
        "explanation": "Specificity: IDs=1, classes/attributes=1, elements=1 → (0,1,1,1). "
                       "This beats any combination of just classes and elements."
    },
    {
        "q": "What does 'box-sizing: border-box' do?",
        "options": [
            "Adds a visible border around all elements",
            "Makes width include content + padding + border (not just content)",
            "Removes all margins from the element",
            "Centers the element in its parent"
        ],
        "answer": 1,
        "explanation": "With border-box, width: 100% INCLUDES padding and border. "
                       "Without it (content-box), padding ADDS to the width causing overflow."
    },
    {
        "q": "What's the difference between textContent and innerHTML?",
        "options": [
            "textContent is faster, innerHTML is slower",
            "textContent is read-only, innerHTML is read-write",
            "textContent treats input as plain text (safe), innerHTML parses HTML (XSS risk)",
            "They do the same thing"
        ],
        "answer": 2,
        "explanation": "innerHTML parses HTML tags — if user input contains <script>, it EXECUTES. "
                       "textContent escapes everything. Always use textContent for untrusted data."
    },
    {
        "q": "In the event loop, what runs first: setTimeout(fn, 0) or Promise.resolve().then(fn)?",
        "options": [
            "setTimeout — it was registered first",
            "Promise.then — microtasks have higher priority than macrotasks",
            "They run at the same time (parallel)",
            "It's random"
        ],
        "answer": 1,
        "explanation": "Microtask queue (Promises) drains COMPLETELY before the event loop "
                       "processes the next macrotask (setTimeout). So Promise.then always runs first."
    },
    {
        "q": "Why does 'for (var i = 0; i < 3; i++) setTimeout(() => console.log(i))' print 3,3,3?",
        "options": [
            "setTimeout is broken",
            "var is function-scoped — all callbacks share the SAME i (which is 3 after the loop)",
            "Closures don't work with var",
            "The loop runs 3 times so it prints 3"
        ],
        "answer": 1,
        "explanation": "var has function scope, not block scope. There's only ONE `i` variable. "
                       "By the time callbacks run, the loop is done and i === 3. Use let to fix it."
    },
    {
        "q": "What does fetch() do when the server returns a 404?",
        "options": [
            "Throws an error (rejects the Promise)",
            "Returns a Response with ok=false — you must check it yourself",
            "Returns null",
            "Retries the request automatically"
        ],
        "answer": 1,
        "explanation": "fetch() only rejects on NETWORK failure (no internet). HTTP errors (404, 500) "
                       "are successful responses from fetch's perspective. Check response.ok!"
    },
    {
        "q": "What is a closure?",
        "options": [
            "A function that closes the browser tab",
            "A function that remembers variables from its outer scope even after that scope has ended",
            "A way to prevent garbage collection",
            "A function defined inside a class"
        ],
        "answer": 1,
        "explanation": "When an inner function references variables from an outer function, "
                       "those variables are 'closed over' — they persist in memory as long as the inner function exists."
    },
    {
        "q": "What does 'display: flex' on a container do to its children?",
        "options": [
            "Makes children invisible",
            "Makes children position:absolute",
            "Lays children along an axis with powerful alignment/distribution controls",
            "Makes children inherit the flex property"
        ],
        "answer": 2,
        "explanation": "Flex items (direct children) are laid out along the main axis. "
                       "You control direction, spacing, alignment with container properties."
    },
    {
        "q": "What does the CSS 'cascade' mean when two rules conflict?",
        "options": [
            "The browser picks randomly",
            "An algorithm resolves conflicts: importance → specificity → source order",
            "The first rule always wins",
            "It causes an error"
        ],
        "answer": 1,
        "explanation": "Cascade algorithm: !important > inline > specificity > later-in-file. "
                       "This is why understanding specificity matters for debugging CSS."
    },
    {
        "q": "Why use encodeURIComponent() in fetch URLs?",
        "options": [
            "To make the URL shorter",
            "To encrypt the data",
            "To safely encode special characters (spaces, &, +) that would break the URL",
            "It's required by the fetch API"
        ],
        "answer": 2,
        "explanation": "'c++' without encoding becomes 'c  ' (+ = space in URLs). "
                       "encodeURIComponent turns it into 'c%2B%2B' which servers parse correctly."
    },
    {
        "q": "What is CORS and why does it exist?",
        "options": [
            "A CSS framework for cross-origin styling",
            "A security mechanism preventing scripts on site A from reading data from site B without permission",
            "A JavaScript library for making requests",
            "A way to share cookies between sites"
        ],
        "answer": 1,
        "explanation": "Without CORS, any website could silently fetch your bank data. "
                       "The server must explicitly allow other origins via Access-Control-Allow-Origin header."
    },
    {
        "q": "What does 'DOMContentLoaded' event tell you?",
        "options": [
            "All images and CSS have finished loading",
            "The HTML is fully parsed and the DOM tree is ready (images may still be loading)",
            "The page is visible to the user",
            "JavaScript files have been downloaded"
        ],
        "answer": 1,
        "explanation": "DOMContentLoaded fires when HTML parsing is complete. 'load' event fires "
                       "when ALL resources (images, CSS, scripts) are done. Use DOMContentLoaded for DOM manipulation."
    },
    {
        "q": "In responsive design, what does this CSS do: td::before { content: attr(data-label); }",
        "options": [
            "Adds a tooltip on hover",
            "Creates a visible label before each table cell using its data-label attribute value",
            "Hides the table cell content",
            "Adds a border before the cell"
        ],
        "answer": 1,
        "explanation": "::before is a pseudo-element that inserts content. attr(data-label) reads "
                       "the HTML attribute. On mobile, we hide table headers and show these labels instead."
    },
    {
        "q": "What's wrong with: element.className = 'active'?",
        "options": [
            "className doesn't exist",
            "It REPLACES all existing classes with just 'active' (removing others)",
            "It adds 'active' to existing classes",
            "Nothing — this is the correct approach"
        ],
        "answer": 1,
        "explanation": "className is a string. Setting it replaces everything. "
                       "Use classList.add('active') to ADD without removing existing classes."
    },
]


def run_quiz():
    print("=" * 60)
    print("  LAYER 1 CHECKPOINT: HTML, CSS, JavaScript")
    print("  Score 12/15 to proceed to Layer 2")
    print("=" * 60)
    print()

    # Shuffle questions for variety on retakes
    shuffled = random.sample(QUESTIONS, len(QUESTIONS))
    score = 0

    for i, q in enumerate(shuffled, 1):
        print(f"Question {i}/15")
        print(f"  {q['q']}")
        print()

        for j, opt in enumerate(q["options"]):
            print(f"    {j + 1}. {opt}")

        print()
        while True:
            try:
                ans = input("  Your answer (1-4): ").strip()
                if ans in ("1", "2", "3", "4"):
                    break
                print("  Please enter 1, 2, 3, or 4.")
            except (EOFError, KeyboardInterrupt):
                print("\n\nQuiz aborted.")
                return

        chosen = int(ans) - 1
        if chosen == q["answer"]:
            print("  ✅ Correct!")
            score += 1
        else:
            correct_text = q["options"][q["answer"]]
            print(f"  ❌ Wrong. Answer: {correct_text}")

        print(f"  💡 {q['explanation']}")
        print()
        print("-" * 60)
        print()

    # Results
    print("=" * 60)
    print(f"  FINAL SCORE: {score}/15")
    print("=" * 60)

    if score >= 12:
        print()
        print("  🎉 PASSED! You're ready for Layer 2 (Backend & Database).")
        print("  Next: mybookshelf/layer2/")
    else:
        print()
        print(f"  📚 Need {12 - score} more correct. Review the files and try again.")
        print("  Focus on the questions you missed — re-read the relevant file.")
    print()


if __name__ == "__main__":
    run_quiz()
