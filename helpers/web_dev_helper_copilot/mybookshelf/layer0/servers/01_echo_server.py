"""
=============================================================================
Level 0.4 — TCP Echo Server (The Simplest Server)
=============================================================================

QUESTIONS (answer these BEFORE reading the code):

  1. What system call creates a socket?
     - socket() → returns a file descriptor (an integer)
     - AF_INET = IPv4, SOCK_STREAM = TCP
     - Think of it as: "give me an endpoint for network communication"

  2. What's the difference between bind, listen, and accept?
     - bind(addr)   → "I want to use THIS address and port"
     - listen(n)    → "I'm ready to receive connections (queue up to n)"
     - accept()     → "Give me the NEXT waiting client" (BLOCKS until one arrives)

     Analogy:
       bind   = put your phone number on a business card
       listen = turn on your phone's ringer
       accept = pick up the phone when it rings

  3. Why do servers call accept() in a loop?
     - accept() returns ONE client connection
     - After serving that client, you want to serve the NEXT one
     - Without a loop, the server handles one client and exits
     - Real servers run forever (until killed)

  4. What happens if two clients connect simultaneously to a single-threaded server?
     - The second client WAITS in the listen queue
     - The server can only handle one at a time
     - The listen(n) backlog 'n' controls how many can wait
     - This is why we need threading/async (Level 0.4 extension)

HOW TO RUN:
  Terminal 1: python3 01_echo_server.py
  Terminal 2: echo "Hello!" | nc localhost 8888
  Terminal 3: ss -tnp | grep 8888  (see the connection)

=============================================================================
"""

import socket
import sys
from datetime import datetime


def main():
    # --- Step 1: Create a socket ---
    # AF_INET = IPv4 (Address Family: Internet)
    # SOCK_STREAM = TCP (reliable, ordered byte stream)
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # SO_REUSEADDR: allow reusing the port immediately after the server stops.
    # Without this, you'd get "Address already in use" for ~60 seconds after restart.
    # Q: Why does the OS hold the port? Look up "TIME_WAIT state" in TCP.
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    # --- Step 2: Bind to an address ---
    # '0.0.0.0' = listen on ALL network interfaces (not just localhost)
    # 8888 = port number (> 1024 so we don't need root)
    host = '0.0.0.0'
    port = 8888
    server.bind((host, port))

    # --- Step 3: Start listening ---
    # 5 = backlog (max number of queued connections waiting for accept)
    server.listen(5)

    print(f"[{datetime.now().strftime('%H:%M:%S')}] Echo server listening on {host}:{port}")
    print(f"  Test with: echo 'Hello!' | nc localhost {port}")
    print(f"  Press Ctrl+C to stop.\n")

    try:
        while True:
            # --- Step 4: Accept a connection ---
            # This BLOCKS until a client connects.
            # Returns: (new_socket_for_this_client, (client_ip, client_port))
            client_sock, client_addr = server.accept()

            timestamp = datetime.now().strftime('%H:%M:%S')
            print(f"[{timestamp}] Connection from {client_addr[0]}:{client_addr[1]}")

            # --- Step 5: Receive data ---
            # recv(1024) reads UP TO 1024 bytes from the client.
            # Q: What if the client sends MORE than 1024 bytes?
            #    Answer: you'd need to call recv() in a loop until you get all the data.
            #    For now, 1024 is enough for simple messages.
            data = client_sock.recv(1024)

            if data:
                message = data.decode('utf-8', errors='replace')
                print(f"[{timestamp}] Received ({len(data)} bytes): {message.strip()}")

                # --- Step 6: Send data back (echo) ---
                # sendall() ensures ALL bytes are sent (send() might only send some)
                client_sock.sendall(data)
                print(f"[{timestamp}] Echoed back to client")
            else:
                print(f"[{timestamp}] Client sent no data (empty connection)")

            # --- Step 7: Close this client's connection ---
            # Q: What happens if we DON'T close?
            #    → File descriptors leak, eventually the OS runs out
            #    → Check with: ls /proc/<pid>/fd | wc -l
            client_sock.close()
            print(f"[{timestamp}] Connection closed\n")

    except KeyboardInterrupt:
        print("\n\nServer stopped.")
    finally:
        server.close()


if __name__ == '__main__':
    main()
