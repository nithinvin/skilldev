# Dynamic Memory — C vs C++

## Side-by-Side

| Operation | C | C++ (Modern) |
|-----------|---|-------------|
| Allocate single | `malloc(sizeof(T))` | `make_unique<T>()` |
| Allocate array | `malloc(n * sizeof(T))` | `make_unique<T[]>(n)` or `vector<T>` |
| Zero-init alloc | `calloc(n, sizeof(T))` | `vector<T>(n, 0)` |
| Resize | `realloc(ptr, new_size)` | `vector::push_back()` (auto) |
| Free | `free(ptr)` | Automatic (RAII) |
| Null check | `if (ptr == NULL)` | Exceptions or `optional` |
| 2D array | Loop of `malloc` | `vector<vector<T>>` |

## Pros & Cons

### C Dynamic Memory (`malloc`/`free`)
✅ Full control over allocation strategy  
✅ `realloc` can resize in-place (efficient)  
✅ No hidden overhead  
✅ Compatible with OS-level memory APIs  
❌ **Memory leaks** — easy to forget `free`  
❌ **Double free** — crashes or security bugs  
❌ **Use-after-free** — undefined behavior  
❌ Must check every allocation for NULL  
❌ Complex cleanup paths (goto-based or nested ifs)  
❌ No exception safety  

### C++ Dynamic Memory (Smart Pointers + RAII)
✅ **No memory leaks** — RAII guarantees cleanup  
✅ **Exception-safe** — resources freed even if exception thrown  
✅ `unique_ptr` has zero overhead over raw pointer  
✅ `vector` replaces all manual array management  
✅ No double-free possible with smart pointers  
✅ Code is shorter and more readable  
❌ `shared_ptr` has overhead (atomic reference counting)  
❌ Circular references need `weak_ptr`  
❌ Custom allocators are more complex to write  
❌ Cannot `realloc` — vector copies on resize  

## The RAII Principle

**Resource Acquisition Is Initialization** — every resource (memory, file, socket, lock) is tied to an object's lifetime:
- Acquire in constructor
- Release in destructor
- Scope controls lifetime

```cpp
{
    auto file = make_unique<File>("data.txt");  // Opens
    file->write("hello");
}  // File automatically closed here — even if exception thrown
```

## Memory Bug Classes Eliminated by C++

| Bug | C | C++ (with smart pointers) |
|-----|---|--------------------------|
| Memory leak | Common | Impossible |
| Double free | Common | Impossible |
| Use-after-free | Common | Very rare |
| Buffer overflow | Common | Prevented by `vector::at()` |
