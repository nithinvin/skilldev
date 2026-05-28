# Hash Table — C vs C++

## Side-by-Side

| Operation | C (Manual) | C++ `unordered_map` | C++ `map` |
|-----------|-----------|--------------------:|----------:|
| Insert | O(1) avg | O(1) avg | O(log n) |
| Lookup | O(1) avg | O(1) avg | O(log n) |
| Delete | O(1) avg | O(1) avg | O(log n) |
| Ordered? | No | No | Yes (sorted) |
| Implementation | Your choice | Hash table | Red-Black Tree |
| Collision handling | Manual | Automatic | N/A |

## Pros & Cons

### C Hash Table
✅ Full control over hash function and collision strategy  
✅ Can optimize for specific key distributions  
✅ Educational — understand hashing deeply  
✅ Can use open addressing (better cache performance)  
❌ ~100 lines of code for basic operations  
❌ Must handle memory for keys/values manually  
❌ Must implement resizing (load factor management)  
❌ Type-specific or relies on `void*`  

### C++ `unordered_map` / `unordered_set`
✅ **One-line operations** — `map[key]++` does insert + increment  
✅ Automatic resizing and load factor management  
✅ Template — works for any hashable type  
✅ Custom hash functions via template parameter  
✅ `unordered_set` for membership testing  
❌ Iteration order is unpredictable  
❌ Worst case O(n) with bad hash function  
❌ More memory overhead than C (allocator, metadata)  
❌ Cannot use with unhashable types without custom hash  

## Key Insight

```cpp
// C: ~20 lines for word counting
// C++: 3 lines!
unordered_map<string, int> freq;
for (auto& word : words)
    freq[word]++;
```

## When to Use What

| Need | Use |
|------|-----|
| O(1) lookup, order doesn't matter | `unordered_map` |
| Sorted keys, range queries | `map` |
| Just membership testing | `unordered_set` / `set` |
| Competitive programming (frequency) | `unordered_map` |
| Custom key types | Define `operator==` + hash struct |

## Common Interview Patterns Using Hash Maps

1. **Two Sum** — complement lookup
2. **Frequency counting** — character/word frequencies
3. **Anagram detection** — sorted string as key
4. **Caching/Memoization** — store computed results
5. **Graph adjacency list** — `unordered_map<int, vector<int>>`
