# Layer 1: Static Web — HTML, CSS, JavaScript

> **Goal**: Understand how browsers render pages. Serve a real website from your own machine.
> **Pre-req**: Layer 0 complete — you understand TCP, HTTP, request/response, ports.
> **Why this matters?** Before adding any backend complexity, understand what the user actually sees. The browser is a runtime environment — HTML is structure, CSS is presentation, JS is behavior.

---

## Level 1.1 — HTML: The Document Tree

### Questions to Answer First
1. What is HTML? Is it a programming language? Why or why not?
2. What does the browser actually do with HTML text? (hint: parsing → DOM tree → rendering)
3. What is the DOM? Why is it a *tree*?
4. Why do we need semantic tags (`<header>`, `<nav>`, `<article>`) when `<div>` works fine?
5. What's the difference between block-level and inline elements?

### Theory (Concise)
```
HTML text → Parser → DOM Tree → Layout → Paint → Pixels on screen

DOM Tree for:  <html><body><h1>Hi</h1><p>Text</p></body></html>

        html
         |
        body
       /    \
     h1      p
     |       |
    "Hi"   "Text"
```

### Hands-On: Build the MyBookShelf Index Page
```html
<!-- file: mybookshelf/index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyBookShelf</title>
</head>
<body>
    <header>
        <h1>📚 MyBookShelf</h1>
        <nav>
            <a href="index.html">Home</a>
            <a href="about.html">About</a>
        </nav>
    </header>

    <main>
        <section id="book-list">
            <h2>My Books</h2>
            <table>
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Author</th>
                        <th>Year</th>
                        <th>Rating</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Code</td>
                        <td>Charles Petzold</td>
                        <td>1999</td>
                        <td>⭐⭐⭐⭐⭐</td>
                    </tr>
                    <tr>
                        <td>The C Programming Language</td>
                        <td>Kernighan & Ritchie</td>
                        <td>1978</td>
                        <td>⭐⭐⭐⭐⭐</td>
                    </tr>
                    <tr>
                        <td>Structure and Interpretation of Computer Programs</td>
                        <td>Abelson & Sussman</td>
                        <td>1996</td>
                        <td>⭐⭐⭐⭐</td>
                    </tr>
                </tbody>
            </table>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 MyBookShelf. Built from scratch.</p>
    </footer>
</body>
</html>
```

### Serve It (Three Ways)
```bash
# Way 1: Python's built-in server (you know what this does from Layer 0!)
cd mybookshelf
python3 -m http.server 8080
# Open http://localhost:8080

# Way 2: Use your own http_server.py from Layer 0 (modify to serve files)
# Way 3: Just open the file directly: file:///path/to/index.html
```

### Explore
- Open browser DevTools (F12) → Elements tab → see the DOM tree
- Right-click an element → "Inspect" — match it to your HTML
- DevTools → Console → type `document.querySelector('h1').textContent` — you just touched the DOM with JS

---

## Level 1.2 — CSS: Styling the Document

### Questions to Answer First
1. What does "cascading" mean in CSS? What's the cascade order?
2. How does the browser decide which CSS rule applies when two rules conflict? (specificity)
3. What's the box model? (content → padding → border → margin)
4. What's the difference between `display: block`, `display: inline`, `display: flex`?
5. Why do we separate style from structure? What problem does this solve?

### Theory (Concise)
```
Specificity (low to high):
  element (h1)  →  class (.title)  →  id (#main)  →  inline style  →  !important

Box Model:
  ┌─────────── margin ───────────┐
  │ ┌──────── border ──────────┐ │
  │ │ ┌───── padding ────────┐ │ │
  │ │ │                      │ │ │
  │ │ │     CONTENT          │ │ │
  │ │ │                      │ │ │
  │ │ └──────────────────────┘ │ │
  │ └──────────────────────────┘ │
  └──────────────────────────────┘
```

### Hands-On: Style MyBookShelf
```css
/* file: mybookshelf/style.css */

/* --- Reset & Base --- */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;  /* Q: Why is this important? */
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: #333;
    max-width: 900px;
    margin: 0 auto;       /* Q: Why does this center the page? */
    padding: 20px;
    background-color: #f5f5f5;
}

/* --- Header --- */
header {
    background-color: #2c3e50;
    color: white;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
}

header h1 {
    font-size: 1.8rem;
}

nav {
    margin-top: 10px;
}

nav a {
    color: #ecf0f1;
    text-decoration: none;
    margin-right: 15px;
    padding: 5px 10px;
    border-radius: 4px;
    transition: background-color 0.3s;  /* Q: What does transition do? */
}

nav a:hover {
    background-color: #34495e;
}

/* --- Book Table --- */
table {
    width: 100%;
    border-collapse: collapse;  /* Q: What happens without this? */
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

th, td {
    padding: 12px 15px;
    text-align: left;
}

th {
    background-color: #3498db;
    color: white;
    font-weight: 600;
}

tr:nth-child(even) {  /* Q: What does this selector do? */
    background-color: #f8f9fa;
}

tr:hover {
    background-color: #e8f4f8;
}

/* --- Footer --- */
footer {
    margin-top: 30px;
    text-align: center;
    color: #777;
    font-size: 0.9rem;
}
```

Link it in your HTML:
```html
<!-- Add inside <head> -->
<link rel="stylesheet" href="style.css">
```

### Break It & Observe
- Remove `box-sizing: border-box` — add a `width: 100%` element with padding. What happens?
- Remove `border-collapse: collapse` from the table. See double borders.
- Change `margin: 0 auto` to `margin: 0` — page is no longer centered. Why?
- Set two conflicting rules: `h1 { color: red; }` and `.title { color: blue; }` — which wins?

---

## Level 1.3 — Responsive Design & Flexbox

### Questions to Answer First
1. What does "responsive" mean? Why do we need it?
2. What is a media query? How does the browser evaluate it?
3. What problem does Flexbox solve that `float` doesn't?
4. What's the difference between `flex-direction: row` and `column`?

### Hands-On: Make It Responsive
```css
/* Add to style.css */

/* --- Card Layout (replace table on mobile) --- */
@media (max-width: 600px) {
    table, thead, tbody, th, td, tr {
        display: block;
    }

    thead {
        display: none;  /* Hide headers on mobile */
    }

    tr {
        margin-bottom: 15px;
        background: white;
        border-radius: 8px;
        padding: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    td {
        padding: 8px;
        text-align: right;
    }

    td::before {
        content: attr(data-label);  /* Q: What is attr()? Where does data-label come from? */
        float: left;
        font-weight: bold;
    }
}
```

Update HTML table cells with `data-label`:
```html
<td data-label="Title">Code</td>
<td data-label="Author">Charles Petzold</td>
```

### Flexbox Exercise
```html
<!-- file: mybookshelf/flexbox-playground.html -->
<!DOCTYPE html>
<html>
<head>
    <style>
        .container {
            display: flex;
            gap: 10px;
            padding: 20px;
            background: #eee;
            /* Try changing these: */
            flex-direction: row;        /* row | column | row-reverse */
            justify-content: flex-start; /* flex-start | center | space-between | space-around */
            align-items: stretch;        /* stretch | center | flex-start | flex-end */
            flex-wrap: wrap;             /* nowrap | wrap */
        }
        .box {
            background: #3498db;
            color: white;
            padding: 20px;
            font-size: 1.2rem;
            border-radius: 4px;
            flex: 0 1 150px;  /* Q: What do these three values mean? */
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="box">1</div>
        <div class="box">2</div>
        <div class="box">3</div>
        <div class="box">4</div>
        <div class="box">5</div>
    </div>
</body>
</html>
```

---

## Level 1.4 — JavaScript: Making Pages Interactive

### Questions to Answer First
1. Where does JavaScript execute? (hint: the browser has a JS engine — V8 in Chrome)
2. What is the event loop? Why is JS single-threaded?
3. What's the difference between the DOM API and JavaScript the language?
4. What does `document.querySelector()` return? How is it related to CSS selectors?
5. What are events? What does "event-driven programming" mean?

### Theory (Concise)
```
JavaScript in the browser:
  - JS engine (V8) executes your code
  - Browser provides APIs: DOM, fetch, setTimeout, localStorage
  - Event loop: call stack → task queue → microtask queue → render

When you write: document.querySelector('h1')
  - "document" = browser-provided global object
  - "querySelector" = DOM API method
  - Returns a reference to the actual DOM node
```

### Hands-On: Add Interactivity to MyBookShelf
```javascript
// file: mybookshelf/app.js

// Wait for DOM to be ready
document.addEventListener('DOMContentLoaded', () => {

    // --- Book data (later this comes from a server) ---
    const books = [
        { title: "Code", author: "Charles Petzold", year: 1999, rating: 5 },
        { title: "The C Programming Language", author: "Kernighan & Ritchie", year: 1978, rating: 5 },
        { title: "SICP", author: "Abelson & Sussman", year: 1996, rating: 4 },
        { title: "Clean Code", author: "Robert Martin", year: 2008, rating: 3 },
        { title: "CLRS Introduction to Algorithms", author: "Cormen et al.", year: 2009, rating: 4 },
    ];

    const tbody = document.querySelector('#book-list tbody');
    const searchInput = document.querySelector('#search');

    // --- Render books into the table ---
    function renderBooks(bookList) {
        tbody.innerHTML = '';  // Q: Is this efficient? What's the alternative?

        bookList.forEach(book => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td data-label="Title">${book.title}</td>
                <td data-label="Author">${book.author}</td>
                <td data-label="Year">${book.year}</td>
                <td data-label="Rating">${'⭐'.repeat(book.rating)}</td>
            `;
            tbody.appendChild(tr);
        });
    }

    // --- Search/filter ---
    searchInput.addEventListener('input', (event) => {
        const query = event.target.value.toLowerCase();
        const filtered = books.filter(book =>
            book.title.toLowerCase().includes(query) ||
            book.author.toLowerCase().includes(query)
        );
        renderBooks(filtered);
    });

    // --- Sort by column ---
    document.querySelectorAll('th').forEach(th => {
        th.style.cursor = 'pointer';
        th.addEventListener('click', () => {
            const key = th.textContent.toLowerCase();
            const sorted = [...books].sort((a, b) => {
                if (typeof a[key] === 'string') return a[key].localeCompare(b[key]);
                return a[key] - b[key];
            });
            renderBooks(sorted);
        });
    });

    // Initial render
    renderBooks(books);
});
```

Update HTML:
```html
<!-- Add before the table -->
<input type="text" id="search" placeholder="Search books..." 
       style="width: 100%; padding: 10px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px;">

<!-- Add before closing </body> -->
<script src="app.js"></script>
```

### Break It & Observe
- Move `<script>` to `<head>` without `DOMContentLoaded` — what breaks? Why?
- Change `innerHTML` to `textContent` — what's the difference? Security implications?
- In console: `document.querySelector('table').remove()` — what happens? Can you undo it?

---

## Level 1.5 — JavaScript Deep Dive: Closures, Promises, Fetch

### Questions to Answer First
1. What is a closure? Why does JavaScript have them?
2. What is a Promise? What problem does it solve compared to callbacks?
3. What does `async/await` compile down to?
4. What is `fetch()`? How does it relate to the HTTP you learned in Layer 0?

### Hands-On: Fetch Data from a Public API
```javascript
// file: mybookshelf/fetch-demo.js

// Fetch books from Open Library API
async function searchOpenLibrary(query) {
    const url = `https://openlibrary.org/search.json?q=${encodeURIComponent(query)}&limit=5`;

    try {
        const response = await fetch(url);  // Q: What HTTP method is this? GET by default

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();  // Q: What does .json() return? A Promise!

        console.log(`Found ${data.numFound} books:`);
        data.docs.forEach(book => {
            console.log(`  ${book.title} by ${book.author_name?.[0] || 'Unknown'} (${book.first_publish_year || 'N/A'})`);
        });

        return data.docs;
    } catch (error) {
        console.error('Failed to fetch:', error.message);
    }
}

// Try it in the browser console:
// searchOpenLibrary("computer science")
```

### Closure Exercise
```javascript
// Q: What does this print? Predict before running.
function createCounter() {
    let count = 0;
    return {
        increment: () => ++count,
        decrement: () => --count,
        getCount: () => count,
    };
}

const counter = createCounter();
console.log(counter.increment());  // ?
console.log(counter.increment());  // ?
console.log(counter.getCount());   // ?
// Can you access `count` directly? Why not?
```

---

## Level 1.6 — Serve Static Files Properly (Python + nginx)

### Questions to Answer First
1. Why not just use `python3 -m http.server` in production?
2. What is nginx? How is it different from your Python HTTP server?
3. What are MIME types? Why does the server need to set `Content-Type` correctly?
4. What does "static file serving" mean vs "dynamic content"?

### Hands-On: nginx on Your Hetzner VM
```bash
# On your Hetzner VM
sudo apt update && sudo apt install nginx -y

# Copy your mybookshelf files
sudo mkdir -p /var/www/mybookshelf
sudo cp -r ~/skilldev/mybookshelf/* /var/www/mybookshelf/

# Configure nginx
sudo tee /etc/nginx/sites-available/mybookshelf << 'EOF'
server {
    listen 80;
    server_name _;   # Accept any hostname

    root /var/www/mybookshelf;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/mybookshelf /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t       # Test config
sudo systemctl restart nginx

# Now access http://<your-hetzner-ip>/ from your browser!
```

### Break It
- Put a file with no extension — what Content-Type does nginx send?
- Request a path like `/../etc/passwd` — does nginx prevent path traversal?
- Stop nginx (`sudo systemctl stop nginx`) — what error does the browser show?

---

## Checkpoint Questions (Answer Before Moving to Layer 2)

1. Explain the rendering pipeline: HTML text → DOM → CSSOM → render tree → layout → paint
2. What is specificity? Give an example where a more "specific" rule overrides a less specific one.
3. What does `display: flex` change about how child elements are laid out?
4. What is the event loop? Draw it from memory: call stack, task queue, microtask queue.
5. Write from memory: a `fetch()` call with error handling that GETs JSON from an API.
6. What's the difference between `textContent` and `innerHTML`? Which is safer? Why?
7. Why does nginx exist when Python can serve files? (think: performance, concurrency, security)

---

## Files Created in This Layer

```
mybookshelf/
├── index.html              # Main page with book table
├── about.html              # Simple about page (create yourself!)
├── style.css               # All styles
├── app.js                  # Search, sort, render
├── fetch-demo.js           # API fetching example
└── flexbox-playground.html # CSS flexbox sandbox
```

---

**Previous**: [Layer 0 — Linux & Networking Foundations](layer0-foundations.md)
**Next**: [Layer 2 — Backend Server & Databases](layer2-backend-db.md)
