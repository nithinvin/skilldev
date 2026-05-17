// This JavaScript file is served by our custom HTTP server!
console.log("app.js loaded — served from raw TCP socket server 🚀");

// Add a dynamic element to prove JS is executing
const footer = document.createElement('p');
footer.style.color = '#888';
footer.style.marginTop = '30px';
footer.textContent = `Page loaded at ${new Date().toLocaleTimeString()} — JS is running!`;
document.body.appendChild(footer);
