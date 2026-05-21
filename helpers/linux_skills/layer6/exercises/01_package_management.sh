#!/bin/bash
# =============================================================================
# Layer 6, Exercise 1: PACKAGE MANAGEMENT
# =============================================================================
# THEORY-IN-ACTION: Package managers solve "dependency hell" — they track
# what software is installed, what depends on what, and handle upgrades
# without breaking things. Every Linux distro has one.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: Package Management — Installing and Managing Software"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: APT (Debian/Ubuntu) ────

    # Update package list (know what's available):
    sudo apt update                     # Downloads latest package index

    # Search for packages:
    apt search "web server"             # Search by description
    apt search nginx
    apt list --installed | wc -l        # How many packages installed?

    # Install:
    sudo apt install tree               # Install a package
    sudo apt install -y curl wget jq    # -y = don't ask for confirmation

    # Package info:
    apt show nginx                      # Details about a package
    apt depends nginx                   # What it needs
    apt rdepends nginx                  # What depends on it
    dpkg -L tree                        # What files did this package install?
    dpkg -S /usr/bin/curl               # Which package owns this file?

    # Remove:
    sudo apt remove tree                # Remove (keep config files)
    sudo apt purge tree                 # Remove + delete config files
    sudo apt autoremove                 # Remove unused dependencies

    # Upgrade:
    sudo apt update && sudo apt upgrade # Update all packages
    sudo apt full-upgrade               # Upgrade + handle dependency changes
    apt list --upgradable               # What CAN be upgraded?

    # Pin/hold a version:
    sudo apt-mark hold nginx            # Don't upgrade nginx
    sudo apt-mark unhold nginx          # Allow upgrades again
    apt-mark showhold                   # See held packages

EXPERIMENT:
    # Where do packages come from?
    cat /etc/apt/sources.list
    ls /etc/apt/sources.list.d/         # Additional repositories

    # Add a PPA (Personal Package Archive):
    # sudo add-apt-repository ppa:deadsnakes/ppa  # Multiple Python versions
    # sudo apt update

    # Download without installing (inspect the .deb):
    apt download tree
    dpkg-deb --contents tree_*.deb | head -20
    rm tree_*.deb

    # Package cache (downloaded .deb files):
    du -sh /var/cache/apt/archives/     # How much space?
    sudo apt clean                       # Clear cache

KEY INSIGHT: `apt update` refreshes the INDEX of available packages.
`apt upgrade` actually INSTALLS updates. Always update before install.
dpkg is the low-level tool; apt is the friendly wrapper.

──── PART 2: dpkg (LOW-LEVEL TOOL) ────

    # dpkg works with individual .deb files (no dependency resolution!):
    # sudo dpkg -i package.deb          # Install a .deb file
    # sudo dpkg -r package              # Remove
    # sudo dpkg --configure -a          # Fix broken installs

    # Useful dpkg queries:
    dpkg -l | head -20                  # All installed packages
    dpkg -l | grep python3              # Installed python3 packages
    dpkg -s coreutils                   # Status of a package
    dpkg -L coreutils | head -20       # Files installed by coreutils

    # When apt breaks (dependency issues):
    # sudo apt --fix-broken install     # Fix dependency problems

──── PART 3: SNAP AND ALTERNATIVES ────

    # Snap (containerized packages):
    snap list                           # Installed snaps
    snap find "vscode"                  # Search
    # sudo snap install code --classic  # Install VS Code

    # Snap vs apt:
    # apt: shared libraries, faster, smaller, traditional
    # snap: self-contained, auto-updates, sandboxed, bigger

    # AppImage (portable, no install):
    # chmod +x myapp.AppImage && ./myapp.AppImage

    # Flatpak (another containerized format):
    # flatpak list

EXPERIMENT:
    # Check your system's package stats:
    echo "Installed packages: $(dpkg -l | grep -c '^ii')"
    echo "Available updates: $(apt list --upgradable 2>/dev/null | grep -c upgradable)"
    echo "Package cache size: $(du -sh /var/cache/apt/archives/ 2>/dev/null | cut -f1)"

KEY INSIGHT: apt = dependency-resolving installer (use this 99% of the time).
dpkg = low-level (for installing .deb files directly).
snap/flatpak = sandboxed apps (when you need isolation or latest versions).

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Next: 02_systemd.sh"
echo "═══════════════════════════════════════════════════════════════"
