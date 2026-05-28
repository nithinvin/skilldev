# Stack — C vs C++

## Side-by-Side

| Feature | C (Array) | C (Linked List) | C++ (Custom) | C++ (`std::stack`) |
|---------|-----------|-----------------|-------------|-------------------|
| Push | O(1) | O(1) | O(1) amortized | O(1) amortized |
| Pop | O(1) | O(1) | O(1) | O(1) |
| Peek | O(1) | O(1) | O(1) | O(1) |
| Size limit | Fixed (`MAX`) | Unlimited | Unlimited | Unlimited |
| Memory | Pre-allocated | Per-node malloc | Vector-backed | deque-backed |
| Type safety | One type per impl | `void*` (unsafe) | Template (safe) | Template (safe) |
| Error handling | Return codes | Return codes | Exceptions | UB if empty |

## Pros & Cons

### C Stack
✅ Simple, minimal code  
✅ Array-based is cache-friendly  
✅ No hidden allocations  
❌ Fixed size (array) or per-node malloc (linked list)  
❌ Must implement for each type or use `void*`  
❌ Error handling via return codes is easy to ignore  

### C++ Stack
✅ Template — works for any type  
✅ Vector-backed — grows automatically, cache-friendly  
✅ Exception on underflow (can't silently fail)  
✅ `std::stack` is adaptor over `deque`/`vector`/`list`  
✅ Clean API — `push()`, `pop()`, `top()`, `empty()`  
❌ `std::stack::pop()` doesn't return value (must call `top()` first)  
❌ No iteration (by design — it's LIFO only)  

## Applications Demonstrated

1. **Balanced Parentheses** — classic interview question
2. **Postfix Expression Evaluation** — calculator logic
3. **Infix to Postfix Conversion** — Shunting-yard algorithm

## `std::stack` Gotcha

```cpp
// WRONG — pop() returns void in STL!
int val = s.pop();  // Compile error!

// CORRECT
int val = s.top();
s.pop();
```

This is by design — separating access from removal provides exception safety.
