# Sorting — C vs C++

## Side-by-Side

| Feature | C `qsort` | C++ `std::sort` |
|---------|-----------|-----------------|
| Complexity | O(n log n) avg | O(n log n) guaranteed (IntroSort) |
| Comparator | Function pointer (`int (*)(const void*, const void*)`) | Lambda, function object, or `<` operator |
| Type safety | `void*` casts required | Template — fully type-safe |
| Stability | Not guaranteed | `stable_sort` available |
| Partial sort | Not available | `partial_sort`, `nth_element` |
| Inline-able | No (function pointer) | Yes (lambdas are inlined) |

## Performance

`std::sort` is typically **2-3x faster** than C's `qsort` because:
1. The comparator (lambda) gets **inlined** — no function pointer overhead
2. IntroSort switches between quicksort, heapsort, and insertion sort optimally
3. Template specialization generates type-specific code

## Pros & Cons

### C `qsort`
✅ Works on any type via `void*`  
✅ Standard C — available everywhere  
✅ Simple API if you know the pattern  
❌ Comparator function cannot be inlined  
❌ `void*` casts are error-prone  
❌ No stability guarantee  
❌ No partial sort or nth_element  

### C++ `std::sort`
✅ Type-safe, no casts  
✅ Lambda comparators are concise and inlined  
✅ Multi-criteria sorting in one lambda  
✅ `stable_sort` for order preservation  
✅ `partial_sort` — only sort what you need  
✅ `nth_element` — O(n) kth smallest  
✅ `is_sorted`, `sort` on any range  
❌ Template code bloat (each type generates new code)  
❌ Complex error messages with wrong comparator  

## Useful Sorting Algorithms in STL

| Function | What it does | Complexity |
|----------|-------------|-----------|
| `sort` | Full sort | O(n log n) |
| `stable_sort` | Preserves equal-element order | O(n log n) |
| `partial_sort` | Sort first K elements | O(n log K) |
| `nth_element` | Put kth element in correct position | O(n) avg |
| `is_sorted` | Check if sorted | O(n) |
| `merge` | Merge two sorted ranges | O(n) |

## Interview Pattern: Sort Indices

```cpp
// Sort indices based on values (without moving values)
vector<int> indices(n);
iota(indices.begin(), indices.end(), 0);
sort(indices.begin(), indices.end(),
     [&values](int a, int b) { return values[a] < values[b]; });
```
