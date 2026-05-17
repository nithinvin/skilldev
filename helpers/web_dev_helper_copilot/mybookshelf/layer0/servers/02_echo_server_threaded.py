"""
=============================================================================
Level 0.4 Extension — Echo Server with Threading + Protocol
=============================================================================

This builds on 01_echo_server.py. Read that first!

WHAT'S NEW:
  1. Threading: handles multiple clients simultaneously
  2. Simple protocol: client sends commands like "UPPER hello" or "REVERSE world"
  3. Connection logging with timestamps

QUESTIONS:
  1. What is a thread? How is it different from a process?
     - Thread = a lightweight execution unit WITHIN a process
     - Threads share memory (same address space). Processes don't.
     - Creating a thread is cheaper than creating a process (no fork)
     - Downside: shared memory → race conditions if not careful
     - Python's GIL means threads don't truly run in parallel for CPU work,
       but they DO help for I/O-bound work (like waiting for network data)

  2. Why use threading here instead of just a loop?
     - With the basic echo server: Client A connects → server handles A → A done → Client B
     - With threading: Client A connects → new thread for A → immediately accept Client B
     - Both clients are served "at the same time" (concurrently)

  3. What is a protocol?
     - An agreement on message FORMAT between client and server
     - HTTP is a protocol. Our simple "COMMAND data" is a protocol too.
     - Without a protocol, client and server can't understand each other.

HOW TO RUN:
  Terminal 1: python3 02_echo_server_threaded.py
  Terminal 2: echo "UPPER hello world" | nc localhost 8889
  Terminal 3: echo "REVERSE python" | nc localhost 8889
  Terminal 4: echo "COUNT hello world foo bar" | nc localhost 8889

=============================================================================
"""

import socket
import threading
from datetime import datetime


def handle_client(client_sock: socket.socket, client_addr: tuple):
    """
    Handle one client connection in its own thread.

    Q: Why pass the socket and address as arguments instead of using globals?
       → Each thread needs its OWN reference to the client socket.
       → If we used a global, all threads would overwrite each other.
    """
    timestamp = datetime.now().strftime('%H:%M:%S')
    thread_name = threading.current_thread().name

    print(f"[{timestamp}] [{thread_name}] Connected: {client_addr[0]}:{client_addr[1]}")

    try:
        data = client_sock.recv(4096)
        if not data:
            print(f"[{timestamp}] [{thread_name}] Empty connection")
            return

        message = data.decode('utf-8', errors='replace').strip()
        print(f"[{timestamp}] [{thread_name}] Received: {message}")

        # --- Parse our simple protocol ---
        # Format: COMMAND argument1 argument2 ...
        parts = message.split(' ', 1)  # Split into command and the rest
        command = parts[0].upper()
        argument = parts[1] if len(parts) > 1 else ''

        # --- Execute the command ---
        if command == 'ECHO':
            response = argument
        elif command == 'UPPER':
            response = argument.upper()
        elif command == 'LOWER':
            response = argument.lower()
        elif command == 'REVERSE':
            response = argument[::-1]
        elif command == 'COUNT':
            words = argument.split()
            response = f"{len(words)} words"
        elif command == 'TIME':
            response = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        elif command == 'HELP':
            response = (
                "Available commands:\n"
                "  ECHO <text>    — Echo back the text\n"
                "  UPPER <text>   — Convert to uppercase\n"
                "  LOWER <text>   — Convert to lowercase\n"
                "  REVERSE <text> — Reverse the text\n"
                "  COUNT <text>   — Count words\n"
                "  TIME           — Get server time\n"
                "  HELP           — Show this help\n"
            )
        else:
            response = f"ERROR: Unknown command '{command}'. Try HELP."

        # Send response back
        client_sock.sendall((response + '\n').encode('utf-8'))
        print(f"[{timestamp}] [{thread_name}] Response: {response[:80]}")

    except Exception as e:
        print(f"[{timestamp}] [{thread_name}] Error: {e}")
    finally:
        client_sock.close()
        print(f"[{timestamp}] [{thread_name}] Disconnected")


def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    host = '0.0.0.0'
    port = 8889
    server.bind((host, port))
    server.listen(10)  # Higher backlog since we can handle more clients

    print(f"[{datetime.now().strftime('%H:%M:%S')}] Threaded echo server on {host}:{port}")
    print(f"  Test: echo 'UPPER hello world' | nc localhost {port}")
    print(f"  Test: echo 'REVERSE python' | nc localhost {port}")
    print(f"  Test: echo 'HELP' | nc localhost {port}")
    print(f"  Press Ctrl+C to stop.\n")

    try:
        client_count = 0
        while True:
            client_sock, client_addr = server.accept()
            client_count += 1

            # Create a new thread for each client
            # daemon=True means the thread dies when the main program exits
            thread = threading.Thread(
                target=handle_client,
                args=(client_sock, client_addr),
                name=f"Client-{client_count}",
                daemon=True,
            )
            thread.start()

            # Q: How many threads are running right now?
            active = threading.active_count()
            print(f"  Active threads: {active} (1 main + {active - 1} client handlers)")

    except KeyboardInterrupt:
        print("\n\nServer stopped.")
    finally:
        server.close()


if __name__ == '__main__':
    main()
