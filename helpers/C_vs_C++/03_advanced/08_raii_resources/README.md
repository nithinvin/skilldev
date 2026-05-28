# RAII & Resource Management — C vs C++

## The Core Problem

Programs acquire resources (memory, files, sockets, locks, database connections). These MUST be released, even when errors occur. How?

## Side-by-Side

| Pattern | C | C++ |
|---------|---|-----|
| Acquire resource | `malloc`, `fopen`, `connect` | Constructor |
| Release resource | `free`, `fclose`, `disconnect` | Destructor (automatic!) |
| Error handling | `goto cleanup` | RAII + exceptions |
| Multiple resources | Nested ifs or goto | Multiple RAII objects |
| Transfer ownership | Pass pointer + convention | `std::move` (compile-time) |
| Shared ownership | Reference counting (manual) | `shared_ptr` (automatic) |

## The C Pattern (goto cleanup)

```c
int process() {
    int result = -1;
    FILE *f = NULL;
    char *buf = NULL;

    f = fopen("data.txt", "r");
    if (!f) goto cleanup;

    buf = malloc(1024);
    if (!buf) goto cleanup;

    // ... work ...
    result = 0;

cleanup:
    free(buf);      // Safe to free(NULL)
    if (f) fclose(f);
    return result;
}
```

## The C++ Pattern (RAII)

```cpp
void process() {
    ifstream f("data.txt");       // Opened in constructor
    auto buf = make_unique<char[]>(1024);  // Allocated

    // ... work ...
    // May throw exception here — STILL safe!

}   // f closed, buf freed — GUARANTEED by destructors
```

## Pros & Cons

### C Resource Management
✅ Explicit — every resource operation is visible  
✅ No hidden behavior  
✅ Works in any C environment  
✅ Predictable performance (no stack unwinding)  
❌ **Error-prone** — easy to forget cleanup  
❌ `goto cleanup` works but is hard to maintain  
❌ Adding new resources requires updating cleanup  
❌ Exception equivalent (`longjmp`) doesn't cleanup  
❌ Every function must handle errors of functions it calls  

### C++ RAII
✅ **Impossible to leak** — destructor always runs  
✅ Works with exceptions — cleanup even on throw  
✅ Composable — RAII objects contain RAII objects  
✅ Move semantics — zero-cost ownership transfer  
✅ `unique_ptr`, `shared_ptr` — general-purpose RAII  
✅ Scope guard pattern for ad-hoc cleanup  
❌ Must understand object lifetime rules  
❌ Circular `shared_ptr` references leak (need `weak_ptr`)  
❌ Move semantics add complexity  
❌ "Moved-from" objects are in valid but unspecified state  

## RAII Applied Everywhere

| Resource | C Cleanup | C++ RAII Wrapper |
|----------|-----------|-----------------|
| Heap memory | `free(ptr)` | `unique_ptr<T>` |
| File | `fclose(fp)` | `ifstream`/`ofstream` |
| Mutex | `pthread_mutex_unlock` | `lock_guard<mutex>` |
| Socket | `close(fd)` | Custom RAII class |
| DB Connection | `disconnect()` | Custom RAII class |
| Thread | `pthread_join` | `std::jthread` (C++20) |

## The Rule of Zero

> If your class uses only RAII members (smart pointers, containers, strings), you don't need to write destructor, copy/move constructors, or assignment operators. **The compiler generates correct ones.**

```cpp
class UserProfile {
    string name;           // Manages its own memory
    vector<string> posts;  // Manages its own memory
    unique_ptr<Image> avatar; // Manages its own memory
    // NO destructor needed! All members are RAII.
};
```

## Key Insight

> RAII is the **single most important idiom in C++**. It eliminates entire classes of bugs (memory leaks, resource leaks, double-free) at compile time. If you learn one thing from C++, learn RAII.
