# Arrays — C vs C++

## Side-by-Side

| Feature | C | C++ |
|---------|---|-----|
| Fixed array | `int arr[10]` | `std::array<int, 10>` |
| Dynamic array | `malloc` + manual `free` | `std::vector<int>` (auto-managed) |
| Size tracking | Must pass separately | `.size()` method |
| Bounds check | None (undefined behavior) | `.at()` throws exception |
| Iteration | Index-based `for` loop | Range-based `for (auto& x : arr)` |
| Algorithms | Write your own | `<algorithm>` — sort, reverse, find, etc. |
| 2D arrays | `int mat[3][3]` | `array<array<int,3>,3>` or `vector<vector<int>>` |

## Pros & Cons

### C Arrays
✅ Zero overhead — direct memory access  
✅ Cache-friendly, predictable layout  
✅ Simple mental model  
❌ No bounds checking — buffer overflows are common  
❌ Size not carried with the array (decays to pointer)  
❌ Dynamic arrays need manual `malloc`/`free`  
❌ No built-in sort, search, reverse  

### C++ `std::array` / `std::vector`
✅ Size is always known (`.size()`)  
✅ Bounds-checked access with `.at()`  
✅ `vector` grows/shrinks automatically  
✅ Works with STL algorithms out of the box  
✅ Memory automatically freed (RAII)  
✅ Range-based `for` eliminates off-by-one errors  
❌ `vector` has slight overhead due to heap allocation  
❌ `push_back` can trigger reallocation (amortized O(1))  
❌ Template syntax can be verbose  

## When to Use What

| Scenario | C approach | C++ approach |
|----------|-----------|-------------|
| Fixed-size, performance-critical | `int arr[N]` | `std::array<int, N>` |
| Unknown size at compile time | `malloc` + `realloc` | `std::vector` |
| Multi-dimensional | `int mat[M][N]` | `vector<vector<int>>` |
| Need sorting/searching | Write your own | Use `<algorithm>` |
