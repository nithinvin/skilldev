#!/bin/bash
# =============================================================================
# Layer 6, Exercise 3: USERS, GROUPS, AND SECURITY
# =============================================================================
# THEORY-IN-ACTION: Linux is multi-user by design. Every process runs as
# some user. Every file is owned by some user. Understanding user management
# = understanding the security boundaries of your system.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: Users, Groups & Security — Who Can Do What"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: USERS AND THE PASSWORD DATABASE ────

    # Who are you?
    whoami                              # Your username
    id                                  # uid, gid, all groups
    id -u                               # Just UID
    id -G                               # All group IDs
    groups                              # Group names

    # All users on the system:
    cat /etc/passwd
    # Format: username:x:uid:gid:comment:home:shell
    # x = password stored in /etc/shadow (not here!)

    # Real users vs system users:
    awk -F: '$3 >= 1000 && $3 < 65000 {print $1, $3}' /etc/passwd  # Real users
    awk -F: '$3 < 1000 {print $1, $3}' /etc/passwd | head -10      # System users

    # Password file (restricted!):
    sudo cat /etc/shadow | head -5
    # Format: username:hashed_password:last_change:min:max:warn:...
    # !! or * = account locked (can't login with password)

    # Groups:
    cat /etc/group
    # Format: groupname:x:gid:member1,member2

    # What groups is a user in?
    groups $USER
    id $USER

EXPERIMENT:
    # Create a user (informational — needs root):
    # sudo useradd -m -s /bin/bash testuser   # -m = create home, -s = shell
    # sudo passwd testuser                     # Set password
    # su - testuser                            # Switch to that user
    # exit                                     # Back to your user
    # sudo userdel -r testuser                 # Remove user + home

    # Add user to a group:
    # sudo usermod -aG docker $USER            # Add to docker group
    # (logout and login for group change to take effect!)

    # Check what you can sudo:
    sudo -l                                    # Your sudo privileges

KEY INSIGHT: UID 0 = root (all-powerful). UIDs 1-999 = system accounts.
UIDs 1000+ = human users. The uid/gid determines ALL access control.
Processes inherit the uid of whoever started them.

──── PART 2: sudo AND PRIVILEGE ESCALATION ────

    # sudo = "substitute user do" (run as another user, default: root)
    sudo whoami                         # root
    sudo -u www-data whoami             # Run as www-data user

    # sudo configuration:
    sudo cat /etc/sudoers               # DON'T edit directly!
    # sudo visudo                       # Safe way to edit sudoers

    # Common sudoers entries:
    # username ALL=(ALL:ALL) ALL        → user can do anything as any user
    # %admin ALL=(ALL) ALL              → admin GROUP can do anything
    # username ALL=(ALL) NOPASSWD: ALL  → no password needed (convenient but risky!)
    # username ALL=(ALL) /usr/bin/apt   → can only run apt as root

    # sudo session:
    sudo -i                             # Full root shell (login shell)
    # exit                              # Back to normal
    sudo -s                             # Root shell (non-login, keeps your env)
    # exit
    sudo bash                           # Run bash as root

    # Security implications:
    # - sudo with password timeout = someone at your desk has 15 min
    # - NOPASSWD = anyone with your session has root
    # - Adding user to 'docker' group = effective root (containers can mount host fs)
    # - Adding user to 'sudo' group = they can do anything

EXPERIMENT:
    # Check sudo log:
    sudo journalctl -u sudo | tail -10   2>/dev/null || \
    sudo grep "sudo" /var/log/auth.log 2>/dev/null | tail -10

    # Who ELSE can sudo?
    grep -E "^[^#].*ALL" /etc/sudoers 2>/dev/null
    ls /etc/sudoers.d/

KEY INSIGHT: sudo is the gatekeeper to root. Principle of least privilege:
give users ONLY the sudo commands they need, not ALL.
Every sudo action is logged — this is your audit trail.

──── PART 3: SSH KEYS AND SECURE ACCESS ────

    # SSH key authentication (password-less, MORE secure):
    ls ~/.ssh/                          # Your SSH files
    # id_rsa / id_ed25519 = private key (NEVER share!)
    # id_rsa.pub / id_ed25519.pub = public key (share freely)
    # authorized_keys = public keys allowed to login as you
    # known_hosts = servers you've connected to before

    # Generate a key pair:
    # ssh-keygen -t ed25519 -C "nithin@mycomputer"
    # (ed25519 is faster and more secure than RSA)

    # Copy your public key to a server:
    # ssh-copy-id user@server           # Adds your pub key to server's authorized_keys

    # SSH config for convenience (~/.ssh/config):
    cat << 'CONFIG'
# Example ~/.ssh/config
Host myserver
    HostName 192.168.1.100
    User nithin
    Port 22
    IdentityFile ~/.ssh/id_ed25519

Host hetzner
    HostName 65.21.x.x
    User root
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
CONFIG
    # Now you can just: ssh myserver (instead of ssh nithin@192.168.1.100)

    # SSH security best practices:
    # 1. Disable password auth (use keys only)
    # 2. Disable root login (use sudo instead)
    # 3. Change default port (22 → something else — stops lazy scanners)
    # 4. Use fail2ban (auto-ban after failed attempts)

    # Check SSH security:
    cat /etc/ssh/sshd_config | grep -E "^(PasswordAuthentication|PermitRootLogin|Port)"

EXPERIMENT:
    # See who's tried to break in:
    sudo journalctl -u sshd | grep "Failed password" | tail -10 2>/dev/null || \
    sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10

    # File permissions for SSH (MUST be correct or SSH refuses to work):
    # ~/.ssh/          → 700 (drwx------)
    # ~/.ssh/id_*      → 600 (-rw-------)
    # ~/.ssh/id_*.pub  → 644 (-rw-r--r--)
    # ~/.ssh/authorized_keys → 600 (-rw-------)

KEY INSIGHT: SSH keys > passwords. A 256-bit key is mathematically harder
to break than any password you could memorize. Always use ed25519 keys.
Permissions on ~/.ssh/ must be restrictive or SSH silently refuses!

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand user management and secure access."
echo "  Layer 6 complete!"
echo "═══════════════════════════════════════════════════════════════"
