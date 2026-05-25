#!/usr/bin/env python3
"""
=============================================================================
Layer 5.1 — Cloud Deployment Script (Hetzner Cloud)
=============================================================================
PURPOSE: Automate server provisioning via Hetzner Cloud API.
Why Hetzner? Cheaper than AWS/GCP for students. Same concepts apply everywhere.

QUESTIONS:
  1. What is "Infrastructure as Code" (IaC)?
     Instead of clicking buttons in a dashboard, you define servers in code.
     Benefits: reproducible, version-controlled, reviewable, automatable.

  2. What is an API token?
     A secret string that proves your identity to the cloud provider.
     NEVER commit it to git. Use environment variables.

  3. What is SSH key authentication?
     Instead of passwords (guessable), use cryptographic key pairs.
     Private key (on your machine) + Public key (on server) = secure login.

  4. What is a "cloud-init" script?
     Commands that run on FIRST boot of a new server.
     Used to: install Docker, create users, configure firewalls, etc.

RUN:
  export HETZNER_API_TOKEN="your-token-here"
  python3 deploy.py create
  python3 deploy.py status
  python3 deploy.py destroy
=============================================================================
"""

import os
import sys
import json
import time

# Q: Why not use requests library directly?
# We use urllib (built-in) so this script has ZERO dependencies.
# In production, you'd use the hcloud Python SDK or Terraform.
from urllib.request import Request, urlopen
from urllib.error import HTTPError


# === CONFIGURATION ===
API_BASE = "https://api.hetzner.cloud/v1"
# Q: What is a server "type"? Pre-configured hardware specs.
# cx22 = 2 vCPU, 4GB RAM, 40GB disk (~€4/month). Perfect for learning.
SERVER_TYPE = "cx22"
IMAGE = "ubuntu-22.04"
LOCATION = "fsn1"  # Falkenstein, Germany (cheapest)
# Q: Why location matters? Latency. Pick the closest to your users.
# fsn1 (Germany), nbg1 (Nuremberg), hel1 (Helsinki), ash (Virginia, US)

# Cloud-init script — runs on first boot
CLOUD_INIT = """#!/bin/bash
# === FIRST BOOT SETUP ===
# Q: Why automate this? So you never manually configure a server.
# If the server dies, run this script → new identical server in 2 minutes.

set -e  # Exit on any error

# Update system
apt-get update && apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose plugin
apt-get install -y docker-compose-plugin

# Create non-root user for deployments
useradd -m -s /bin/bash deploy
usermod -aG docker deploy

# Basic firewall
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw --force enable

# Install fail2ban (blocks brute-force SSH attempts)
apt-get install -y fail2ban
systemctl enable fail2ban

echo "=== Server setup complete ==="
"""


def get_token():
    """Get API token from environment variable."""
    token = os.environ.get("HETZNER_API_TOKEN")
    if not token:
        print("ERROR: Set HETZNER_API_TOKEN environment variable")
        print("  export HETZNER_API_TOKEN='your-token-here'")
        print("  Get token: https://console.hetzner.cloud → Security → API Tokens")
        sys.exit(1)
    return token


def api_request(method, endpoint, data=None):
    """
    Make authenticated request to Hetzner API.
    Q: What is a Bearer token?
       Authorization: Bearer <token> — standard way to send API credentials.
       "Bearer" = "I'm bearing (carrying) this token as proof of identity."
    """
    url = f"{API_BASE}{endpoint}"
    headers = {
        "Authorization": f"Bearer {get_token()}",
        "Content-Type": "application/json",
    }

    body = json.dumps(data).encode() if data else None
    req = Request(url, data=body, headers=headers, method=method)

    try:
        with urlopen(req) as response:
            if response.status == 204:  # No content (e.g., after DELETE)
                return None
            return json.loads(response.read())
    except HTTPError as e:
        error_body = e.read().decode()
        print(f"API Error {e.code}: {error_body}")
        sys.exit(1)


def create_server():
    """
    Provision a new cloud server.
    Q: What happens when you call this?
    1. Hetzner receives API request
    2. Allocates hardware in their datacenter
    3. Installs Ubuntu from image
    4. Runs cloud-init script
    5. Returns server IP address
    Total time: ~30 seconds. That's cloud computing.
    """
    print("Creating server 'mybookshelf-prod'...")

    data = {
        "name": "mybookshelf-prod",
        "server_type": SERVER_TYPE,
        "image": IMAGE,
        "location": LOCATION,
        "user_data": CLOUD_INIT,  # Cloud-init script
        # Q: In production, you'd also specify:
        # "ssh_keys": [key_id],  ← pre-uploaded SSH public key
        # "firewalls": [fw_id],  ← network-level firewall rules
    }

    result = api_request("POST", "/servers", data)
    server = result["server"]
    root_password = result.get("root_password", "N/A (SSH key auth)")

    print(f"\n✓ Server created!")
    print(f"  ID:       {server['id']}")
    print(f"  IP:       {server['public_net']['ipv4']['ip']}")
    print(f"  Status:   {server['status']}")
    print(f"  Password: {root_password}")
    print(f"\n  SSH in:   ssh root@{server['public_net']['ipv4']['ip']}")
    print(f"  Wait ~2 min for cloud-init to complete.")
    print(f"\n  Next: deploy your Docker Compose stack to this server.")

    return server


def list_servers():
    """List all your servers."""
    result = api_request("GET", "/servers")
    servers = result["servers"]

    if not servers:
        print("No servers found.")
        return

    print(f"\n{'Name':<25} {'IP':<16} {'Status':<12} {'Type':<8}")
    print("-" * 65)
    for s in servers:
        ip = s["public_net"]["ipv4"]["ip"]
        print(f"{s['name']:<25} {ip:<16} {s['status']:<12} {s['server_type']['name']:<8}")


def destroy_server(name="mybookshelf-prod"):
    """
    Delete a server.
    Q: Why is this dangerous?
    - All data on the server is PERMANENTLY deleted
    - No undo, no recovery
    - In production: use backups, snapshots, or persistent volumes
    """
    result = api_request("GET", "/servers")
    for s in result["servers"]:
        if s["name"] == name:
            confirm = input(f"DELETE server '{name}' (IP: {s['public_net']['ipv4']['ip']})? [y/N] ")
            if confirm.lower() == "y":
                api_request("DELETE", f"/servers/{s['id']}")
                print(f"✓ Server '{name}' deleted.")
            else:
                print("Cancelled.")
            return
    print(f"Server '{name}' not found.")


def deploy_to_server(ip):
    """
    Deploy Docker Compose stack to remote server.
    Q: What is this doing?
    1. Copy files to server via scp
    2. SSH in and run docker compose up
    This is a simple approach. Production uses: Ansible, Terraform, or Kubernetes.
    """
    print(f"Deploying to {ip}...")
    print(f"""
    Run these commands manually (or automate with a script):

    # 1. Copy project files to server
    scp -r ../layer4/* deploy@{ip}:~/mybookshelf/

    # 2. SSH in and start services
    ssh deploy@{ip} << 'EOF'
        cd ~/mybookshelf
        docker compose pull
        docker compose up -d
        docker compose ps
    EOF

    # 3. Verify
    curl http://{ip}/health
    curl http://{ip}/api/books
    """)


# === CLI Interface ===
def main():
    if len(sys.argv) < 2:
        print("Usage: python3 deploy.py <command>")
        print("  create   — Create a new server")
        print("  list     — List all servers")
        print("  destroy  — Delete a server")
        print("  deploy   — Show deploy commands")
        sys.exit(1)

    command = sys.argv[1]

    if command == "create":
        create_server()
    elif command == "list":
        list_servers()
    elif command == "destroy":
        destroy_server()
    elif command == "deploy":
        if len(sys.argv) < 3:
            print("Usage: python3 deploy.py deploy <server-ip>")
            sys.exit(1)
        deploy_to_server(sys.argv[2])
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
