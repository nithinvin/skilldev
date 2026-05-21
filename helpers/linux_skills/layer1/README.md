# Layer 1: Files & The Filesystem

## What You'll Learn
- The filesystem hierarchy (what lives in /, /etc, /var, /proc, /dev)
- File operations (cp, mv, rm, mkdir, find — your daily tools)
- Permissions (rwx, chmod, chown, umask — the security model)
- Links and inodes (how files REALLY work under the hood)

## File Structure

```
layer1/
├── README.md              ← You are here
└── exercises/
    ├── 01_filesystem_tour.sh      ← /, /etc, /proc, /dev, /var layout
    ├── 02_file_operations.sh      ← cp, mv, rm, find, touch, mkdir
    └── 03_permissions.sh          ← rwx, chmod, chown, umask, special bits
```

## How to Work Through This

```bash
cd ~/skilldev/helpers/linux_skills/layer1

# Same approach: open in editor, type into terminal manually
cat exercises/01_filesystem_tour.sh
# ... type commands ...

cat exercises/02_file_operations.sh
cat exercises/03_permissions.sh
```

## Prerequisites
- Complete Layer 0 (you should be comfortable with pipes and redirection)

## Key Takeaway
"Everything is a file" isn't just a slogan. Devices, processes, network sockets — they all appear as files. Once you understand this, Linux stops being mysterious.

## Time Estimate
~3 hours (about 1 hour per exercise)
