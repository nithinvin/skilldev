# Layer 1: Files & The Filesystem

> **Goal**: Understand "everything is a file" — the most important idea in Linux.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_filesystem_tour.sh` | /, /home, /etc, /var, /proc, /dev, /tmp layout |
| `02_file_operations.sh` | cp, mv, rm, mkdir, touch, find, locate |
| `03_permissions.sh` | rwx, chmod, chown, chgrp, umask, sticky bit |
| `04_links_and_inodes.sh` | hard links, symlinks, inodes, what rm really does |
| `05_disk_and_mount.sh` | df, du, lsblk, mount, /etc/fstab |

---

## Key Ideas (Discovered Through Practice)

- **The filesystem is a tree** — rooted at `/`, every path is a walk down this tree
- **Inodes hold the real data** — filenames are just labels pointing to inodes
- **Permissions are a 3×3 matrix** — read/write/execute × owner/group/others
- **Devices are files** — `/dev/sda` is your disk, `/dev/null` is a black hole
- **`/proc` is a window into the kernel** — live system info, no actual files on disk

---

## Checkpoint

1. What is an inode? What information does it store?
2. You delete a file but `du` still shows disk usage. Why? (hint: open file descriptors)
3. A file has permissions `rwxr-x---`. Who can execute it?
4. What's the difference between `/tmp` and `/var/tmp`?
5. How can you find all files larger than 100MB on your system?
