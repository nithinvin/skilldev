# DEBRIEF: The Locked Room

## Solution

### Flag 1
The directory `vault/` has permission `644` (rw-r--r--).
That's READ and WRITE but no EXECUTE.

**Key insight:** For directories, `x` (execute) means "permission to TRAVERSE."
- `r` on a directory = can LIST contents (ls)
- `x` on a directory = can ENTER it (cd) and access files inside
- Without `x`: you can see file names but can't read/open them!

**Fix:** `chmod +x vault/` → now you can `cd vault/` and `cat flag1.txt`

**FLAG{execute_permission_on_directories_means_traverse}**

### Flag 2
Inside `vault/inner/` (permission 711 = rwx--x--x):
- You CAN enter (x is set for others)
- You CANNOT list contents (r is NOT set for others)
- But if you KNOW the filename, you can access it!

`cat vault/inner/flag2.txt` works if the file itself is readable by you.
Since flag2.txt is 600 (rw-------), only the owner can read it.
Since YOU ran setup.sh, YOU are the owner!

**FLAG{read_permission_is_separate_from_list_permission}**

## Mental Model

```
DIRECTORY permissions:
  r (read)    = can LIST filenames inside (ls)
  w (write)   = can CREATE/DELETE files inside
  x (execute) = can ENTER (cd) and ACCESS files by name

FILE permissions:
  r (read)    = can view contents (cat, less)
  w (write)   = can modify contents
  x (execute) = can run as a program

KEY INSIGHT: These are DIFFERENT meanings for the same letters!

Permission Math (octal):
  r = 4, w = 2, x = 1
  rwx = 7, rw- = 6, r-x = 5, r-- = 4
  
  644 = rw-r--r-- (owner: rw, group: r, others: r)
  755 = rwxr-xr-x (typical for executables/directories)
  700 = rwx------ (only owner has access)
```

## Real-World Application
- Web servers: HTML files need 644, directories need 755
- Private keys (SSH): MUST be 600 or ssh refuses to use them
- `/tmp` has sticky bit: anyone can create files, only owner can delete
- Docker containers running as root = dangerous (all files accessible)

## Skills Unlocked
- `chmod` — change permissions (symbolic: +x, numeric: 755)
- `ls -la` — read permission strings
- Understanding octal notation
- Directory vs file permission semantics
