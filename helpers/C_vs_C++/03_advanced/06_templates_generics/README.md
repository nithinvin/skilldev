# Templates & Generics — C vs C++

## Approaches to Generic Programming

| Approach | Language | Type Safety | Performance | Flexibility |
|----------|---------|------------|------------|-------------|
| `void*` | C | ❌ None | Runtime overhead | High |
| Macros (`#define`) | C | ❌ None | Zero overhead | Medium |
| `_Generic` (C11) | C | ✅ Compile-time | Zero overhead | Limited |
| Templates | C++ | ✅ Compile-time | Zero overhead | Very High |

## Side-by-Side

| Feature | C | C++ |
|---------|---|-----|
| Generic swap | `memcpy` with `void*` + size | `template<typename T> void swap(T&, T&)` |
| Generic container | Macro-generated or `void*` | `template<typename T> class Container` |
| Type dispatch | `_Generic` or function pointers | Overloading + template specialization |
| Variadic | `va_args` (unsafe) | Variadic templates (type-safe) |
| Constraints | Manual documentation | `concepts` (C++20) / `enable_if` |

## Pros & Cons

### C Generics
✅ `void*` — works at runtime for any type  
✅ Macros — zero overhead, expanded at compile time  
✅ `_Generic` — compile-time type dispatch  
✅ Simple mental model  
❌ `void*` loses all type information — errors at runtime  
❌ Macros produce unreadable error messages  
❌ Macros don't respect scope or namespaces  
❌ No way to express constraints ("must be comparable")  
❌ Code duplication with macros  

### C++ Templates
✅ **Zero-cost abstraction** — no runtime overhead  
✅ Full type safety — errors at compile time  
✅ Specialization — custom behavior for specific types  
✅ Variadic templates — type-safe variable arguments  
✅ Works with type traits for compile-time decisions  
✅ Enables STL (entirely template-based)  
❌ **Error messages are notoriously long and cryptic**  
❌ Each instantiation generates new code (binary bloat)  
❌ Compilation is slower  
❌ Complex template metaprogramming is hard to understand  

## Template Instantiation

```cpp
// When you write:
vector<int> v1;
vector<string> v2;

// Compiler generates TWO separate classes:
// class vector_int { ... }
// class vector_string { ... }
// This is why templates must be in headers
```

## C++20 Concepts (Future-proof)

```cpp
// Instead of enable_if gymnastics:
template <typename T>
concept Sortable = requires(T a, T b) { a < b; };

template <Sortable T>
void sort(vector<T>& v) { /* ... */ }
```

## Key Insight

> Templates are C++'s **most powerful feature**. They enable:
> - STL containers and algorithms
> - Zero-cost abstractions
> - Compile-time computation
> - Policy-based design
