# DEBRIEF: Operation Dead Drop

## Full Walkthrough

### Stage 1: The Entry Point
```bash
cat /tmp/dead_drop_op/public/notice.txt
# Find the base64 string in the "maintenance note"
echo "L3RtcC9kZWFkX2Ryb3Bfb3Avc3RhZ2UyLw==" | base64 -d
# Result: /tmp/dead_drop_op/stage2/
```
**Lesson:** Always check for hidden data in plain-text files. Attackers embed commands in comments, metadata, and "innocent" notices.

### Stage 2: Hidden Files
```bash
cd /tmp/dead_drop_op/stage2/
ls -la          # intel.gpg is a decoy
cat .actual_intel   # The REAL intel is hidden
```
**Lesson:** Hidden files (dotfiles) are trivially findable with `ls -a`. "Security through hiding" is not security.

### Stage 3: Process Environment
```bash
# Find the disguised process
ps aux | grep thermal_monitor
# Get its PID, read its environment
cat /proc/<PID>/environ | tr '\0' '\n' | grep DEAD_DROP_KEY
# Key is: nautilus
```
**Lesson:** Process environments (`/proc/PID/environ`) leak secrets. Never store passwords in environment variables on shared systems.

### Stage 4: Network Forensics
```bash
# Read the capture log, find the data exfiltration
grep "exfil" /tmp/dead_drop_op/stage4/capture.log
# Decode the base64 data parameter
echo "RkxBR3tuZXR3b3JrX2ZvcmVuc2ljc19maW5kX3RoZV9leGZpbHRyYXRpb259" | base64 -d
# FLAG{network_forensics_find_the_exfiltration}
```
**Lesson:** Data exfiltration often hides in URL parameters, POST bodies, or DNS queries. Base64 in URLs is suspicious.

### Stage 5: Assembly
```bash
# Decode all parts
PART1=$(cat /tmp/dead_drop_op/stage5/part1.b64 | base64 -d)
PART2=$(cat /tmp/dead_drop_op/stage5/part2.hex | xxd -r -p)
PART3=$(cat /tmp/dead_drop_op/stage5/part3.b64 | base64 -d)
echo "${PART1}${PART2}${PART3}"
# FLAG{dead_drop_operation_complete_you_are_a_ghost}
```

### Bonus Flag
Reading the deploy script source: **FLAG{you_read_the_source_code_thats_called_recon}**

## All Flags
| Stage | Flag |
|-------|------|
| 4 | FLAG{network_forensics_find_the_exfiltration} |
| 5 | FLAG{dead_drop_operation_complete_you_are_a_ghost} |
| Bonus | FLAG{you_read_the_source_code_thats_called_recon} |

## Skills Demonstrated
- Base64 encoding/decoding
- Hidden file discovery (dotfiles)
- Process enumeration and /proc filesystem
- Environment variable extraction
- Network log analysis
- Hex decoding
- Multi-format data assembly
- Source code review (recon)

## Operational Thinking

```
The OODA Loop (military decision-making):
  OBSERVE  → What do I see? What's unusual?
  ORIENT   → What does this mean? What format is this?
  DECIDE   → What's my next move? What tool do I need?
  ACT      → Execute. Check result. Loop back to Observe.

Applied to each stage:
  Stage 1: OBSERVE the notice → ORIENT on base64 → DECODE
  Stage 2: OBSERVE the directory → ORIENT on hidden files → LIST ALL
  Stage 3: OBSERVE the hint → ORIENT on /proc → EXTRACT from environ
  Stage 4: OBSERVE the log → ORIENT on suspicious data → DECODE
  Stage 5: OBSERVE multiple files → ORIENT on formats → ASSEMBLE
```

## Time Benchmarks
- Under 30 min: Ghost tier — you've done this before
- 30-60 min: Specialist — solid Linux skills
- 60-90 min: Operative — learning fast
- 90+ min: Recruit — but you finished, and that's what matters
