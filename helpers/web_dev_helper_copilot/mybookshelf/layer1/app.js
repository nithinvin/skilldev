/*
=============================================================================
Level 1.4 — JavaScript: Making It Interactive
=============================================================================

QUESTIONS (answer these BEFORE reading the code):

  1. What is the DOM?
     - Document Object Model
     - The browser parses HTML → builds a TREE of objects in memory
     - Each element becomes a "node" you can read/change with JavaScript
     - Changing the DOM = changing what's displayed (without reloading!)

  2. What's the difference between textContent and innerHTML?
     textContent: just the text (safe — no HTML parsing)
     innerHTML: full HTML (DANGEROUS if you inject user input! → XSS attacks)
     Rule: use textContent unless you specifically need to insert HTML.

  3. What does DOMContentLoaded mean?
     The HTML has been fully parsed and the DOM tree is ready.
     Images/CSS may still be loading, but the structure exists.
     Always wrap your code in this event to ensure elements exist!

  4. What are event listeners?
     You "listen" for user actions: click, keyup, submit, scroll...
     element.addEventListener('event', handlerFunction)
     When the event fires, your function runs.

  5. What's the difference between var, let, and const?
     var: function-scoped, hoisted (avoid — legacy)
     let: block-scoped, reassignable
     const: block-scoped, NOT reassignable (preferred for most things)

  6. Array methods you should know:
     .filter(fn)  — return items where fn returns true (creates NEW array)
     .map(fn)     — transform each item (creates NEW array)
     .sort(fn)    — sort in place (mutates! use [...arr].sort() for safety)
     .forEach(fn) — loop over items (no return value)
     .find(fn)    — return FIRST item where fn returns true

=============================================================================
*/

// Q: Why is this at the top? This is our data source.
// In Layer 2, this will come from a server/database instead.
const books = [
    { id: 1, title: "Clean Code", author: "Robert C. Martin", year: 2008, genre: "Programming" },
    { id: 2, title: "The Pragmatic Programmer", author: "Hunt & Thomas", year: 1999, genre: "Programming" },
    { id: 3, title: "SICP", author: "Abelson & Sussman", year: 1996, genre: "Computer Science" },
    { id: 4, title: "Design Patterns", author: "Gang of Four", year: 1994, genre: "Software Engineering" },
    { id: 5, title: "Introduction to Algorithms", author: "Cormen et al.", year: 2009, genre: "Computer Science" },
    { id: 6, title: "You Don't Know JS", author: "Kyle Simpson", year: 2014, genre: "JavaScript" },
    { id: 7, title: "Eloquent JavaScript", author: "Marijn Haverbeke", year: 2018, genre: "JavaScript" },
    { id: 8, title: "The C Programming Language", author: "K&R", year: 1978, genre: "Programming" },
];

// === DOM REFERENCES ===
// Q: Why grab these once? Each document.querySelector() searches the entire DOM.
// Storing the result in a variable = one search, reuse everywhere.
const tableBody = document.querySelector("#book-table tbody");
const searchInput = document.querySelector("#search");
const tableHeaders = document.querySelectorAll("#book-table th");

// === STATE ===
// Q: What's "state"? The current condition of your app.
// What's the current sort column? Direction? Search query?
let currentSort = { column: "title", ascending: true };
let searchQuery = "";


// =============================================================================
// RENDER FUNCTION
// =============================================================================
// Q: Why one render function? Single source of truth for what's displayed.
// Any change (search, sort) → update state → call render() → DOM updates.
// This pattern will scale to React/Vue later (Layer 3+).

function renderBooks() {
    // Step 1: Filter by search query
    // Q: What does .filter() do? Creates a NEW array with only matching items.
    const filtered = books.filter(book => {
        const query = searchQuery.toLowerCase();
        return (
            book.title.toLowerCase().includes(query) ||
            book.author.toLowerCase().includes(query) ||
            book.genre.toLowerCase().includes(query)
        );
        // Q: Why .toLowerCase() on both sides?
        // Makes search case-insensitive: "clean" matches "Clean Code"
    });

    // Step 2: Sort the filtered results
    const sorted = [...filtered].sort((a, b) => {
        // Q: Why [...filtered] (spread into new array)?
        // .sort() MUTATES the original array! We don't want to change `filtered`.
        // Spread creates a copy. Sort the copy.
        const col = currentSort.column;
        let valA = a[col];
        let valB = b[col];

        // Strings: compare case-insensitively
        if (typeof valA === "string") {
            valA = valA.toLowerCase();
            valB = valB.toLowerCase();
        }

        if (valA < valB) return currentSort.ascending ? -1 : 1;
        if (valA > valB) return currentSort.ascending ? 1 : -1;
        return 0;
        // Q: How does .sort(compareFn) work?
        // Return negative → a comes first
        // Return positive → b comes first
        // Return 0 → keep original order
    });

    // Step 3: Build HTML and insert into DOM
    // Q: Why not create elements one by one with createElement()?
    // For simple tables, building an HTML string and setting innerHTML is simpler.
    // BUT: never do this with user-provided data (XSS risk!).
    // Our data is hardcoded above, so it's safe here.
    tableBody.innerHTML = sorted.map(book => `
        <tr>
            <td data-label="Title">${escapeHtml(book.title)}</td>
            <td data-label="Author">${escapeHtml(book.author)}</td>
            <td data-label="Year">${book.year}</td>
            <td data-label="Genre">${escapeHtml(book.genre)}</td>
        </tr>
    `).join("");
    // Q: Why .join("")? .map() returns an array of strings.
    // .join("") merges them into one big string. Without it you'd get commas between rows.

    // Update result count
    updateResultCount(sorted.length);
}


// =============================================================================
// SECURITY: HTML ESCAPING
// =============================================================================
// Q: What is XSS (Cross-Site Scripting)?
// If user input contains <script>...</script> and you inject it with innerHTML,
// the browser EXECUTES that script! An attacker can steal cookies, redirect, etc.
// ALWAYS escape HTML entities when inserting dynamic content.

function escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
    // Q: Trick — setting textContent escapes HTML entities automatically.
    // Then reading innerHTML gives us the escaped version.
    // "< script >" becomes "&lt;script&gt;" — safe to insert!
}


// =============================================================================
// SEARCH
// =============================================================================

searchInput.addEventListener("input", (event) => {
    // Q: Why "input" event and not "keyup"?
    // "input" fires for ANY change: typing, paste, cut, speech-to-text.
    // "keyup" only fires for physical key releases (misses paste via mouse).
    searchQuery = event.target.value;
    renderBooks();
});


// =============================================================================
// SORTING
// =============================================================================

tableHeaders.forEach(th => {
    th.addEventListener("click", () => {
        const column = th.dataset.sort;
        // Q: What is dataset? Every data-* attribute is accessible via element.dataset.
        // <th data-sort="title"> → th.dataset.sort === "title"

        if (!column) return; // Skip headers without data-sort

        if (currentSort.column === column) {
            // Same column clicked → toggle direction
            currentSort.ascending = !currentSort.ascending;
        } else {
            // New column → sort ascending
            currentSort.column = column;
            currentSort.ascending = true;
        }

        // Update visual indicators
        updateSortIndicators();
        renderBooks();
    });
});

function updateSortIndicators() {
    tableHeaders.forEach(th => {
        th.classList.remove("sort-asc", "sort-desc");
        if (th.dataset.sort === currentSort.column) {
            th.classList.add(currentSort.ascending ? "sort-asc" : "sort-desc");
        }
    });
    // Q: classList.add/remove is the RIGHT way to toggle CSS classes.
    // Never manipulate className directly (it replaces ALL classes).
}


// =============================================================================
// RESULT COUNT
// =============================================================================

function updateResultCount(count) {
    let countEl = document.querySelector("#result-count");
    if (!countEl) {
        // Create it if it doesn't exist yet
        countEl = document.createElement("p");
        countEl.id = "result-count";
        countEl.style.color = "#777";
        countEl.style.fontSize = "0.9rem";
        countEl.style.marginBottom = "10px";
        searchInput.insertAdjacentElement("afterend", countEl);
        // Q: insertAdjacentElement — precise DOM insertion without innerHTML.
        // Positions: "beforebegin", "afterbegin", "beforeend", "afterend"
    }
    countEl.textContent = `Showing ${count} of ${books.length} books`;
}


// =============================================================================
// INITIALIZATION
// =============================================================================
// Q: Why wait for DOMContentLoaded?
// If this script runs before the HTML is parsed, querySelector("#book-table") → null!
// DOMContentLoaded guarantees all elements exist in the tree.

document.addEventListener("DOMContentLoaded", () => {
    renderBooks();
    updateSortIndicators();
});

// BREAK IT exercises:
// 1. Remove the DOMContentLoaded wrapper. What happens? (Hint: check console errors)
// 2. Change escapeHtml to just return the raw text. Try adding a book with title "<b>test</b>"
// 3. Remove [...filtered] spread and sort filtered directly. Call renderBooks twice. What's different?
// 4. Change "input" event to "keyup". Try pasting text with Ctrl+V. Does search update?
// 5. Set box-sizing to content-box in CSS and add padding to #search. Does it overflow?
