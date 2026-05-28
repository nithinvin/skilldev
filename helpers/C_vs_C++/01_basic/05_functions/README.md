# Functions — C vs C++

## Side-by-Side

| Feature | C | C++ |
|---------|---|-----|
| Overloading | ❌ Not supported | ✅ Same name, different params |
| Default args | ❌ Not supported | ✅ `void f(int x = 10)` |
| Pass by reference | Pointer: `void f(int *x)` | Reference: `void f(int& x)` |
| Generic functions | `void*` or macros | Templates: `template<typename T>` |
| Anonymous functions | ❌ Not available | Lambdas: `[](int x){ return x*2; }` |
| Higher-order | Function pointers | `std::function`, lambdas |
| Variadic | `stdarg.h` (unsafe) | Variadic templates (type-safe) |

## Pros & Cons

### C Functions
✅ Simple and predictable — one name = one function  
✅ Function pointers are lightweight  
✅ No name mangling — easy to link with other languages  
✅ ABI stability  
❌ No overloading — must invent different names (`add_int`, `add_float`)  
❌ No default arguments — all params required  
❌ Function pointers have ugly syntax  
❌ `va_args` is not type-safe  

### C++ Functions
✅ Overloading makes APIs cleaner — same name for related operations  
✅ Default args reduce the need for multiple function versions  
✅ References are safer and cleaner than pointers  
✅ Templates enable type-safe generic programming  
✅ Lambdas enable functional programming style  
✅ Works seamlessly with STL algorithms  
❌ Overloading can be confusing with implicit conversions  
❌ Template errors produce notoriously long error messages  
❌ Name mangling makes C++ harder to interface with C  
❌ `std::function` has overhead compared to raw function pointers  

## Lambda Syntax Quick Reference

```cpp
// Basic lambda
auto square = [](int x) { return x * x; };

// With capture (access outer variables)
int factor = 3;
auto multiply = [factor](int x) { return x * factor; };

// Capture by reference
auto increment = [&factor]() { factor++; };

// Capture all by value [=] or all by reference [&]
auto all_by_ref = [&]() { /* can access all outer vars */ };
```
