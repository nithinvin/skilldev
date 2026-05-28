# STL Containers — C vs C++

## The Big Picture

What takes **100+ lines of C code** (dynamic array, set, map implementations) is available in **one line** in C++ via STL:

```cpp
vector<int> v;          // Dynamic array
set<int> s;             // Sorted unique elements
map<string, int> m;     // Sorted key-value pairs
unordered_map<K, V> um; // Hash map
priority_queue<int> pq; // Max-heap
```

## Container Quick Reference

| Container | When to Use | C Equivalent |
|-----------|------------|-------------|
| `vector<T>` | Default container. Random access, grow/shrink | `realloc`-based array |
| `deque<T>` | Fast insert/remove at both ends + random access | Circular buffer |
| `list<T>` | Frequent insert/remove in middle | Doubly-linked list |
| `set<T>` | Unique sorted elements, range queries | Sorted array + binary search |
| `map<K,V>` | Sorted key-value, range queries | Sorted struct array |
| `unordered_set<T>` | Fast membership test | Hash table |
| `unordered_map<K,V>` | Fast key-value lookup | Hash table |
| `priority_queue<T>` | Always access max/min | Binary heap |
| `stack<T>` | LIFO | Array with top pointer |
| `queue<T>` | FIFO | Circular buffer |

## Pros & Cons

### Manual C Implementations
✅ Understand internals deeply (crucial for DSA courses)  
✅ Can optimize for specific patterns  
✅ No library dependency  
✅ Minimal binary size  
❌ Hundreds of lines for basic operations  
❌ Bug-prone (off-by-one, memory leaks)  
❌ Type-specific or unsafe `void*`  
❌ No standard interface across implementations  

### C++ STL Containers
✅ **Tested, optimized, production-ready**  
✅ Generic — work for any type via templates  
✅ Consistent interface (`.begin()`, `.end()`, `.size()`)  
✅ Work with STL algorithms (`sort`, `find`, `accumulate`)  
✅ Exception-safe, RAII-compliant  
✅ Iterators provide uniform traversal  
❌ Template error messages are cryptic  
❌ May allocate more memory than needed  
❌ Black-box — harder to reason about exact behavior  
❌ Learning curve for choosing the right container  

## Decision Flowchart

```
Need a collection?
├── Need key-value pairs?
│   ├── Ordered by key → std::map
│   └── Just fast lookup → std::unordered_map
├── Just unique elements?
│   ├── Need sorted → std::set
│   └── Just membership → std::unordered_set
├── Ordered sequence?
│   ├── Random access needed → std::vector (default!)
│   ├── Insert/remove at both ends → std::deque
│   └── Insert/remove in middle → std::list
└── Special access pattern?
    ├── LIFO → std::stack
    ├── FIFO → std::queue
    └── Priority → std::priority_queue
```

## Golden Rule

> When in doubt, use `std::vector`. It's the fastest container for most real-world workloads due to cache locality.
