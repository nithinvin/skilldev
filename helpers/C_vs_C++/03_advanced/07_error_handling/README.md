# Error Handling — C vs C++

## Approaches Comparison

| Approach | C | C++ |
|----------|---|-----|
| Return codes | `int func()` returns error code | Same (still valid) |
| errno | Global `errno` variable | Inherited from C |
| goto cleanup | `goto cleanup;` pattern | Replaced by RAII |
| setjmp/longjmp | Non-local jump (fragile) | Replaced by exceptions |
| Exceptions | ❌ Not available | `try/catch/throw` |
| Optional values | Return sentinel (-1, NULL) | `std::optional` (C++17) |
| Result types | Not standard | `std::variant` or `std::expected` (C++23) |

## Pros & Cons

### C Error Handling
✅ Explicit — every error path is visible in code  
✅ No hidden control flow  
✅ Zero runtime overhead (no unwinding)  
✅ Compatible with all ABIs  
❌ Easy to **forget** to check return codes  
❌ Error propagation requires manual forwarding  
❌ `goto cleanup` is the cleanest pattern (but `goto` is stigmatized)  
❌ `setjmp/longjmp` doesn't call destructors — unsafe in C++  
❌ `errno` is global — not thread-safe in old code  

### C++ Exceptions
✅ **Cannot be ignored** — uncaught exceptions terminate the program  
✅ Separate error handling from normal logic  
✅ Exception hierarchy enables catch-by-type  
✅ RAII ensures cleanup even with exceptions  
✅ Propagate automatically up the call stack  
❌ Performance cost when thrown (stack unwinding)  
❌ Hidden control flow — hard to reason about  
❌ Every function might throw (unless `noexcept`)  
❌ Not suitable for real-time or embedded systems  

### C++ `std::optional` (C++17)
✅ No exception overhead  
✅ Explicit "might not have a value" in the type system  
✅ `value_or(default)` for safe access  
❌ Only for "absent" vs "present" — no error details  

## The RAII + Exceptions Guarantee

```cpp
void function() {
    DatabaseConnection db("main");  // Acquired
    auto buffer = make_unique<int[]>(1000);  // Acquired

    may_throw();  // If this throws...

    // db destructor called — connection closed
    // buffer deleted — memory freed
    // GUARANTEED even with exception
}
```

## Best Practice Guidelines

| Scenario | Recommendation |
|----------|---------------|
| Programming error (bug) | `assert()` — crash immediately |
| Expected absence | `std::optional` |
| Recoverable runtime error | Exceptions |
| Performance-critical hot path | Return codes or `optional` |
| Library boundary | Return codes (exceptions don't cross ABI) |
| Embedded/real-time | Return codes only (no exceptions) |

## Exception Safety Levels

| Level | Guarantee | Example |
|-------|----------|---------|
| No-throw | Never throws | `noexcept` functions, destructors |
| Strong | Operation succeeds or state unchanged | Copy-and-swap idiom |
| Basic | No leaks, invariants maintained | Most well-written code |
| None | May leak or corrupt | ❌ Never acceptable |
