# Layer 1: Static Web — HTML, CSS, JavaScript

## What You'll Learn
- HTML5 semantic elements (the structure)
- CSS3 layout, box model, flexbox, responsive design (the style)
- JavaScript DOM manipulation, events, async patterns (the behavior)
- How browsers actually render pages
- Security basics (XSS, escaping, CORS)

## File Structure

```
mybookshelf/layer1/
├── index.html              ← Main page: book table with search & sort
├── about.html              ← About page: semantic HTML showcase (ol, dl, blockquote)
├── style.css               ← All CSS: reset, layout, responsive, mobile cards
├── app.js                  ← DOM manipulation: render, search, sort, events
├── flexbox-playground.html ← Interactive: change flex properties, see results live
├── js-playground.html      ← Demos: closures, promises, event loop, scope, arrays
├── fetch-demo.js           ← Async: Open Library API, timeout, retry, parallel fetch
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions on everything in this layer
```

## How to Work Through This Layer

### Prerequisites
- Complete Layer 0 (you should understand HTTP, TCP, how servers work)
- A modern browser (Chrome/Firefox) with DevTools

### Order

1. **Read `index.html`** — Open in a text editor. Read every HTML comment/question.
   Then open in browser. Right-click → Inspect → Elements tab to see the DOM tree.

2. **Read `style.css`** — Follow the questions at the top (box model, specificity).
   In DevTools: inspect elements, toggle CSS properties on/off, see what changes.

3. **Open `about.html`** — Study semantic elements (ol, dl, blockquote, footer).
   These matter for accessibility and SEO.

4. **Read `app.js`** — Understand renderBooks() pattern (state → filter → sort → render).
   In DevTools Console: type `books`, `searchQuery`, `currentSort` to inspect state.

5. **Play with `flexbox-playground.html`** — Change every dropdown. Read the cheat sheet.
   Challenge: Can you center a div vertically AND horizontally? (2 properties!)

6. **Run each demo in `js-playground.html`** — PREDICT the output before clicking Run.
   The event loop demo is the most important — understand why the order is 1, 4, 3, 2.

7. **Experiment with `fetch-demo.js`** — Open any page, open Console, paste functions.
   Try: `searchBooks("python")`. Watch the network tab in DevTools.

8. **Do all "BREAK IT" exercises** — These teach you WHY things work by breaking them.

9. **Run `checkpoint_quiz.py`** — Must score 12/15 to proceed to Layer 2.

### How to Serve These Files

```bash
# From the layer1 directory:
cd mybookshelf/layer1
python3 -m http.server 8000

# Or use Layer 0's file server:
python3 ../layer0/servers/04_http_file_server.py
```

Then open http://localhost:8000 in your browser.

### DevTools Tips (Chrome)
- `F12` or `Ctrl+Shift+I` → Open DevTools
- **Elements tab**: See/edit DOM and CSS live
- **Console tab**: Run JavaScript, see errors
- **Network tab**: See every HTTP request (fetch calls, CSS/JS loading)
- **Responsive mode**: `Ctrl+Shift+M` → Test mobile layouts
- **Disable cache**: Network tab → check "Disable cache" (avoids stale CSS)

## Key Concepts Covered

| Level | Topic | File |
|-------|-------|------|
| 1.1 | Semantic HTML, tables, forms | index.html, about.html |
| 1.2 | CSS box model, specificity, cascade | style.css |
| 1.3 | Flexbox, responsive design, media queries | style.css, flexbox-playground.html |
| 1.4 | DOM, events, state management | app.js |
| 1.5 | Promises, async/await, fetch, event loop | js-playground.html, fetch-demo.js |

## Connection to Other Layers

- **Layer 0** → You built the HTTP server that SERVES these files
- **Layer 2** → The hardcoded `books` array will come from a real database
- **Layer 3** → fetch-demo.js patterns become real API calls to YOUR backend
- **Layer 4** → These files get bundled, minified, and deployed via CI/CD
