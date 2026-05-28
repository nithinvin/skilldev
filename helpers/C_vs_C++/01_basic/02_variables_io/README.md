# Variables & I/O — C vs C++

## Key Differences

| Feature | C | C++ |
|---------|---|-----|
| String type | `char[]` (fixed buffer) | `std::string` (dynamic) |
| Input | `scanf("%d", &var)` | `cin >> var` |
| Full line input | `fgets(buf, size, stdin)` | `getline(cin, str)` |
| Type inference | Not available | `auto` (C++11) |
| Declaration location | Top of block (C89) | Anywhere |
| Initialization | `int x = 10;` | `int x{10};` (brace init prevents narrowing) |

## Pros & Cons

### C
✅ Explicit and predictable — what you see is what you get  
✅ No hidden allocations (`char[]` is stack-allocated)  
✅ Format strings let you control exact output layout easily  
❌ Buffer overflow risk with `scanf` (must use width specifiers)  
❌ No type checking on format strings  
❌ String handling is manual and error-prone  

### C++
✅ `std::string` handles memory automatically — no overflow  
✅ `cin >>` is type-safe — wrong type = failed stream, not UB  
✅ `auto` reduces redundancy for complex types  
✅ Brace initialization catches accidental narrowing at compile time  
❌ `cin >>` stops at whitespace (need `getline` for full lines)  
❌ Mixing `cin >>` and `getline` causes subtle bugs (leftover newline)  
❌ `auto` can make code harder to read if overused  

## Common Pitfall

```cpp
// After cin >> age, the newline stays in buffer
cin >> age;
getline(cin, name);  // reads empty string!

// Fix: add cin.ignore() before getline
cin >> age;
cin.ignore(numeric_limits<streamsize>::max(), '\n');
getline(cin, name);
```
