# Pointers — C vs C++

## Side-by-Side

| Feature | C | C++ |
|---------|---|-----|
| Null pointer | `NULL` (macro for 0) | `nullptr` (type-safe) |
| References | ❌ Not available | `int& ref = x` |
| Smart pointers | ❌ Manual `malloc/free` | `unique_ptr`, `shared_ptr`, `weak_ptr` |
| Pass by ref | `void f(int *x)` | `void f(int& x)` |
| Generic pointer | `void*` | Templates (type-safe) |
| Array allocation | `malloc` + `free` | `make_unique<int[]>(n)` |
| Double pointer | `int **pp` | Rarely needed (use references) |

## Pros & Cons

### C Pointers
✅ Full control over memory layout  
✅ `void*` enables generic data structures  
✅ Function pointers for callbacks  
✅ Minimal runtime overhead  
❌ **Dangling pointers** — use-after-free bugs  
❌ **Memory leaks** — forget to `free`  
❌ **Buffer overflows** — no bounds checking  
❌ Double-free causes crashes  
❌ `NULL` is just `0` — can be confused with integer  

### C++ Pointers & References
✅ **References** — cannot be null, cannot be reassigned (safer)  
✅ **Smart pointers** eliminate memory leaks by design  
✅ `unique_ptr` — zero overhead over raw pointer  
✅ `shared_ptr` — reference counting for shared ownership  
✅ `nullptr` — type-safe, no integer confusion  
✅ RAII ensures cleanup even with exceptions  
❌ `shared_ptr` has overhead (atomic ref count)  
❌ Circular references with `shared_ptr` leak (need `weak_ptr`)  
❌ Still possible to use raw pointers unsafely  

## Smart Pointer Decision Guide

```
Do you need shared ownership?
├── YES → shared_ptr (+ weak_ptr for observers)
└── NO
    ├── Does ownership transfer? → unique_ptr
    └── Just observing? → raw pointer or reference
```

## Key Rule

> In modern C++, **raw `new`/`delete` should almost never appear** in application code. Use `make_unique` or `make_shared` instead.
