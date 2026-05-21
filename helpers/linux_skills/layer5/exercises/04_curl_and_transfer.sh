#!/bin/bash
# =============================================================================
# Layer 5, Exercise 4: CURL, WGET, AND DATA TRANSFER
# =============================================================================
# THEORY-IN-ACTION: curl and wget let you interact with web services from
# the command line. curl is especially powerful — it speaks HTTP, HTTPS, FTP,
# and more. It's how you test APIs, download files, and debug web services.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 4: curl & Transfer — Talk to the Web from Terminal"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: curl BASICS ────

    # Simple GET request:
    curl https://httpbin.org/get             # Returns JSON showing your request
    curl -s https://httpbin.org/get          # -s = silent (no progress bar)
    curl -sS https://httpbin.org/get         # -sS = silent but show errors

    # See response headers:
    curl -I https://google.com              # -I = HEAD request (headers only)
    curl -i https://httpbin.org/get         # -i = include headers in output
    curl -v https://httpbin.org/get         # -v = verbose (see full request/response)

    # Follow redirects:
    curl -L https://google.com             # -L follows 301/302 redirects
    curl -IL https://google.com            # See the redirect chain

    # Download a file:
    curl -o /tmp/example.html https://example.com  # -o = output to file
    curl -O https://example.com/index.html          # -O = use remote filename
    curl -# -o /tmp/big.file https://speed.hetzner.de/100MB.bin  # Progress bar

    # Timeout:
    curl -m 5 https://httpbin.org/delay/10   # Max 5 seconds (will timeout)
    curl --connect-timeout 3 https://example.com  # Connection timeout only

EXPERIMENT:
    # See exactly what curl sends:
    curl -v https://httpbin.org/get 2>&1 | grep "^[><]"
    # > lines = what curl SENT
    # < lines = what the server RESPONDED

    # Test your internet speed:
    curl -o /dev/null -w "Speed: %{speed_download} bytes/sec\nTime: %{time_total}s\n" \
        https://speed.hetzner.de/1MB.bin

KEY INSIGHT: curl's most important flags:
-s (silent), -S (show errors), -L (follow redirects), -o (output file),
-v (verbose/debug), -i (include headers), -I (headers only).

──── PART 2: HTTP METHODS AND APIs ────

    # POST request (send data):
    curl -X POST https://httpbin.org/post \
        -H "Content-Type: application/json" \
        -d '{"name": "Nithin", "age": 19}'

    # POST form data:
    curl -X POST https://httpbin.org/post \
        -d "username=nithin&password=secret"

    # PUT (update):
    curl -X PUT https://httpbin.org/put \
        -H "Content-Type: application/json" \
        -d '{"status": "updated"}'

    # DELETE:
    curl -X DELETE https://httpbin.org/delete

    # Custom headers:
    curl -H "Authorization: Bearer mytoken123" \
         -H "X-Custom-Header: myvalue" \
         https://httpbin.org/headers

    # Read response as JSON (pipe to jq):
    curl -s https://httpbin.org/get | python3 -m json.tool  # Pretty-print
    # OR if jq is installed:
    # curl -s https://httpbin.org/get | jq .

    # Save and reuse cookies:
    curl -c /tmp/cookies.txt https://httpbin.org/cookies/set/session/abc123 -L
    curl -b /tmp/cookies.txt https://httpbin.org/cookies
    rm /tmp/cookies.txt

EXPERIMENT:
    # Talk to a real API:
    # GitHub API (public, no auth needed):
    curl -s https://api.github.com/users/torvalds | python3 -m json.tool | head -20

    # Weather API:
    curl -s "https://wttr.in/Chennai?format=3"

    # HTTP status code only:
    curl -s -o /dev/null -w "%{http_code}" https://google.com
    echo  # newline

KEY INSIGHT: curl is your API testing tool. Every REST API interaction
you'd do in Postman, you can do with curl. The advantage: scriptable,
reproducible, and works over SSH.

──── PART 3: wget AND OTHER TRANSFER TOOLS ────

    # wget — simpler for downloading:
    wget -q https://example.com -O /tmp/example.html  # Quiet, output to file
    wget -q --spider https://google.com && echo "URL exists"  # Just check

    # wget can mirror entire sites:
    # wget --mirror --convert-links --page-requisites https://example.com

    # scp — copy files over SSH:
    # scp local_file.txt user@remote:/path/to/dest/
    # scp user@remote:/path/to/file.txt ./local_copy.txt
    # scp -r local_dir/ user@remote:/path/  # Recursive

    # rsync — smart sync (only transfers differences):
    # rsync -avz source/ dest/              # Local sync
    # rsync -avz -e ssh source/ user@remote:/dest/  # Over SSH
    # Flags: -a (archive), -v (verbose), -z (compress), --progress

    # Key difference: scp vs rsync:
    # scp = simple copy (always transfers everything)
    # rsync = smart sync (only transfers changed bytes)
    # For large/repeated transfers, rsync is MUCH faster

    # nc (netcat) for raw transfer:
    # Receiver: nc -l 9999 > received_file.txt
    # Sender:   cat file.txt | nc receiver_host 9999
    # Fast but no encryption!

EXPERIMENT:
    # Resume interrupted download:
    curl -C - -O https://speed.hetzner.de/1MB.bin  # -C - = resume

    # Upload a file (to test endpoint):
    echo "test data" > /tmp/upload_test.txt
    curl -X POST https://httpbin.org/post \
        -F "file=@/tmp/upload_test.txt"
    rm /tmp/upload_test.txt

    # Parallel downloads:
    for url in https://example.com https://httpbin.org/get https://google.com; do
        curl -sL -o /dev/null -w "%{url_effective}: %{http_code}\n" "$url" &
    done
    wait

KEY INSIGHT: curl for HTTP interactions and API testing.
wget for simple downloads and site mirroring.
rsync for file synchronization (beats scp for repeated transfers).
nc for raw TCP — useful for debugging and quick transfers.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can interact with web services from the terminal."
echo "  Layer 5 complete!"
echo "═══════════════════════════════════════════════════════════════"
