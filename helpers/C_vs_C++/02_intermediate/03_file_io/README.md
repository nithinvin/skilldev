# File I/O — C vs C++

## Side-by-Side

| Operation | C | C++ |
|-----------|---|-----|
| Open | `fopen("f.txt", "r")` | `ifstream file("f.txt")` |
| Close | `fclose(fp)` | Automatic (RAII) or `file.close()` |
| Write text | `fprintf(fp, "%d", x)` | `file << x` |
| Read text | `fscanf(fp, "%d", &x)` | `file >> x` |
| Read line | `fgets(buf, size, fp)` | `getline(file, str)` |
| Write binary | `fwrite(ptr, size, n, fp)` | `file.write(ptr, size)` |
| Read binary | `fread(ptr, size, n, fp)` | `file.read(ptr, size)` |
| Error check | `if (fp == NULL)` | `if (!file)` |
| EOF check | `feof(fp)` or check return | `while (getline(...))` |

## Pros & Cons

### C File I/O
✅ Simple, well-understood API  
✅ `fprintf`/`fscanf` with format strings are powerful  
✅ Direct binary I/O with fixed-size structs is trivial  
✅ Works identically across C and C++  
❌ Must remember to `fclose` every opened file  
❌ No automatic cleanup on error paths  
❌ Buffer overflow risk with `fscanf`  
❌ No exception safety — errors need manual checking  

### C++ File I/O (fstream)
✅ **RAII** — files close automatically at scope exit  
✅ Type-safe — no format string bugs  
✅ Works with `<<`/`>>` operators (extensible for custom types)  
✅ Exception-safe — file closed even if exception thrown  
✅ `stringstream` provides in-memory formatting/parsing  
❌ Binary I/O with variable-length strings is more complex  
❌ Verbose for simple tasks  
❌ Stream state management (`fail()`, `eof()`, `clear()`) is confusing  
❌ Slower than C I/O in some benchmarks (but usually negligible)  

## Best Practice

```cpp
// Always use RAII — never manually close
{
    ofstream file("data.txt");
    file << "hello";
}  // Closed here automatically

// For performance-critical I/O:
ios_base::sync_with_stdio(false);  // Disable C/C++ stream sync
cin.tie(nullptr);                  // Untie cin from cout
```
