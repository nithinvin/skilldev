/*
=============================================================================
Level 1.5 — Fetch API: Talking to Servers
=============================================================================

QUESTIONS (answer these BEFORE reading the code):

  1. What is an API?
     - Application Programming Interface
     - A set of rules for how software components communicate
     - Web API: server exposes URLs (endpoints) that return data (usually JSON)
     - Example: GET https://openlibrary.org/search.json?q=javascript
       → returns a JSON object with book search results

  2. What is JSON?
     - JavaScript Object Notation
     - Text format for structured data: {"key": "value", "num": 42, "arr": [1,2]}
     - Language-agnostic (Python, Java, Go all use JSON)
     - response.json() parses the text into a JavaScript object

  3. What is fetch()?
     - Built-in browser function for making HTTP requests
     - Returns a Promise (it's async — network is slow!)
     - fetch(url) → Promise<Response> → response.json() → Promise<data>

  4. What's the difference between fetch and XMLHttpRequest?
     - XMLHttpRequest (XHR) is the old way — callback-based, verbose
     - fetch() is modern — Promise-based, cleaner syntax
     - fetch doesn't reject on HTTP errors (404, 500)! Must check response.ok

  5. What is CORS?
     - Cross-Origin Resource Sharing
     - Browser security: scripts on site A can't fetch from site B by default
     - Server B must send "Access-Control-Allow-Origin" header to permit it
     - Open Library allows CORS, so our demo works from localhost

=============================================================================
HOW TO USE THIS FILE:
  Open index.html (or any page) in the browser.
  Open DevTools → Console tab.
  Copy-paste functions from this file to experiment.
  
  OR: Add <script src="fetch-demo.js"></script> to index.html temporarily.
=============================================================================
*/

// === BASIC FETCH: Search Open Library ===

async function searchBooks(query) {
    // Q: Why async? fetch() returns a Promise. We need to WAIT for the network.
    // Without async/await, we'd need .then().then().catch() chains.

    const url = `https://openlibrary.org/search.json?q=${encodeURIComponent(query)}&limit=5`;
    // Q: Why encodeURIComponent?
    // Spaces and special chars break URLs. This encodes them safely:
    // "clean code" → "clean%20code"

    console.log(`🔍 Searching for "${query}"...`);

    try {
        const response = await fetch(url);
        // Q: What is `response`?
        // A Response object with: status (200, 404, 500), ok (bool), headers, body
        // The body hasn't been read yet! We must call .json() or .text()

        if (!response.ok) {
            // Q: Why check response.ok?
            // fetch() does NOT throw on HTTP errors (404, 500)!
            // It only throws on NETWORK failure (no internet, DNS error).
            // You must check .ok yourself. Many beginners miss this!
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        // Q: Why another await? .json() also returns a Promise
        // (reading the body is async — could be a large payload)

        console.log(`✅ Found ${data.numFound} total results (showing ${data.docs.length}):`);
        console.log("");

        data.docs.forEach((book, index) => {
            console.log(`  ${index + 1}. "${book.title}"`);
            console.log(`     Author: ${book.author_name ? book.author_name[0] : "Unknown"}`);
            console.log(`     Year: ${book.first_publish_year || "Unknown"}`);
            console.log("");
        });

        return data.docs;

    } catch (error) {
        // Q: What errors can we catch here?
        // 1. Network failure (no internet, timeout) → TypeError: Failed to fetch
        // 2. Our thrown HTTP error (from !response.ok check)
        // 3. JSON parse error (server returned invalid JSON)
        console.error(`❌ Error: ${error.message}`);
        return [];
    }
}


// === PARALLEL REQUESTS: Fetch multiple things at once ===

async function searchMultiple(queries) {
    // Q: What's Promise.all?
    // Runs multiple promises IN PARALLEL and waits for ALL to complete.
    // If ANY one fails, the whole thing fails (use Promise.allSettled to avoid this).

    console.log(`🚀 Searching for ${queries.length} queries in parallel...`);
    const startTime = Date.now();

    try {
        const results = await Promise.all(
            queries.map(q => searchBooks(q))
        );
        // Q: Why is this faster than awaiting one by one?
        // Sequential: query1 (1s) + query2 (1s) + query3 (1s) = 3s total
        // Parallel: all start at once, total time = slowest one (~1s)

        const elapsed = Date.now() - startTime;
        console.log(`⏱️ All ${queries.length} searches completed in ${elapsed}ms`);
        return results;

    } catch (error) {
        console.error(`❌ One of the requests failed: ${error.message}`);
        return [];
    }
}


// === FETCH WITH TIMEOUT: Don't wait forever ===

async function fetchWithTimeout(url, timeoutMs = 5000) {
    // Q: Why add a timeout? fetch() has NO built-in timeout!
    // A slow server could hang your app forever.
    // AbortController lets us cancel the request.

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

    try {
        const response = await fetch(url, { signal: controller.signal });
        clearTimeout(timeoutId); // Success — cancel the timeout
        return response;
    } catch (error) {
        clearTimeout(timeoutId);
        if (error.name === "AbortError") {
            throw new Error(`Request timed out after ${timeoutMs}ms`);
        }
        throw error; // Re-throw network errors
    }
}


// === FETCH WITH RETRY: Handle temporary failures ===

async function fetchWithRetry(url, maxRetries = 3, delayMs = 1000) {
    // Q: Why retry? Networks are unreliable. A 503 might work on next attempt.
    // Exponential backoff: wait longer between each retry (1s, 2s, 4s)

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            console.log(`  Attempt ${attempt}/${maxRetries}...`);
            const response = await fetchWithTimeout(url, 5000);

            if (response.ok) return response;

            // Retry on server errors (5xx), not client errors (4xx)
            if (response.status >= 500) {
                throw new Error(`Server error: ${response.status}`);
            }

            // Client error (404, 403) — don't retry, it won't help
            throw new Error(`Client error: ${response.status} (not retrying)`);

        } catch (error) {
            if (attempt === maxRetries || error.message.includes("not retrying")) {
                throw error;
            }
            // Exponential backoff
            const wait = delayMs * Math.pow(2, attempt - 1);
            console.log(`  ⚠️ ${error.message}. Retrying in ${wait}ms...`);
            await new Promise(resolve => setTimeout(resolve, wait));
        }
    }
}


// === PUTTING IT TOGETHER: Fetch and display on the page ===

async function fetchAndDisplayBooks(query) {
    const resultsDiv = document.getElementById("fetch-results");
    if (!resultsDiv) {
        console.log("No #fetch-results element found. Run from index.html or add one.");
        console.log("Falling back to console output...");
        return searchBooks(query);
    }

    resultsDiv.innerHTML = "<p>🔍 Searching...</p>";

    try {
        const books = await searchBooks(query);

        if (books.length === 0) {
            resultsDiv.innerHTML = "<p>No books found.</p>";
            return;
        }

        // Q: Why build DOM with createElement instead of innerHTML here?
        // This data comes from an EXTERNAL API — we can't trust it!
        // Using textContent (not innerHTML) prevents XSS attacks.
        const list = document.createElement("ul");
        books.forEach(book => {
            const li = document.createElement("li");
            const title = book.title || "Unknown";
            const author = book.author_name ? book.author_name[0] : "Unknown";
            li.textContent = `${title} by ${author} (${book.first_publish_year || "?"})`;
            list.appendChild(li);
        });

        resultsDiv.innerHTML = "";
        resultsDiv.appendChild(list);

    } catch (error) {
        resultsDiv.innerHTML = `<p style="color:red">Error: ${error.message}</p>`;
    }
}


// =============================================================================
// TRY THESE IN THE CONSOLE:
// =============================================================================
//
// searchBooks("javascript")
// searchBooks("clean code")
// searchMultiple(["python", "algorithms", "design patterns"])
// fetchAndDisplayBooks("computer science")
//
// =============================================================================

// BREAK IT exercises:
// 1. Try searchBooks("") — what happens with an empty query?
// 2. Disconnect from internet and call searchBooks("test") — what error do you get?
// 3. Change the URL to a non-existent endpoint — does fetch throw or return a 404?
// 4. Remove the encodeURIComponent — search for "c++" — what goes wrong?
// 5. Change Promise.all to Promise.allSettled — how does error handling differ?
