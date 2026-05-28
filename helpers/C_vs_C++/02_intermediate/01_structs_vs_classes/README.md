# Structs vs Classes — C vs C++

## Side-by-Side

| Feature | C Struct | C++ Class |
|---------|----------|-----------|
| Data members | ✅ | ✅ |
| Methods | ❌ (use function pointers) | ✅ Built-in |
| Access control | ❌ Everything public | `private`, `protected`, `public` |
| Constructors | ❌ (factory functions) | ✅ Constructors/Destructors |
| Inheritance | ❌ (embed structs) | ✅ `class Derived : public Base` |
| Polymorphism | Function pointers (manual vtable) | `virtual` functions (automatic vtable) |
| Operator overloading | ❌ | ✅ `operator+`, `operator<<`, etc. |
| Encapsulation | Convention only | Enforced by compiler |

## Pros & Cons

### C Structs
✅ Simple data containers — easy to understand  
✅ No hidden behavior — what you see is what happens  
✅ Compatible with binary serialization  
✅ Can be passed to hardware / network directly  
❌ No encapsulation — anyone can modify any field  
❌ No inheritance — code reuse requires embedding + manual dispatch  
❌ Polymorphism via function pointers is error-prone  
❌ No destructors — must remember to cleanup manually  

### C++ Classes
✅ **Encapsulation** — private data can't be accidentally corrupted  
✅ **Constructors** ensure objects are always in valid state  
✅ **Destructors** enable RAII (automatic cleanup)  
✅ **Inheritance** enables code reuse and "is-a" relationships  
✅ **Virtual functions** enable runtime polymorphism cleanly  
✅ **Operator overloading** makes user types feel like built-in types  
❌ Deep inheritance hierarchies become hard to understand  
❌ Virtual functions have slight overhead (vtable lookup)  
❌ Copy semantics can be surprising (Rule of 3/5/0)  
❌ More complex mental model  

## Design Guideline

> **C++**: Prefer composition over inheritance. Use inheritance only for "is-a" relationships. Prefer `final` classes unless you explicitly design for inheritance.

## The Rule of Five (C++11)

If your class manages a resource (memory, file handle, socket), you need:
1. Destructor
2. Copy constructor
3. Copy assignment operator
4. Move constructor
5. Move assignment operator

Or just use smart pointers and follow the **Rule of Zero** — let the compiler generate all five.
