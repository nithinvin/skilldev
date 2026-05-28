# Linked List — C vs C++

## Side-by-Side

| Operation | C | C++ (Custom) | C++ (STL `std::list`) |
|-----------|---|-------------|----------------------|
| Create | `malloc` + init | Constructor | `list<int> l` |
| Insert front | Manual pointer update | `push_front()` | `push_front()` |
| Insert back | Traverse + insert | `push_back()` | `push_back()` |
| Delete | Find + unlink + `free` | `remove()` + `delete` | `remove(val)` |
| Search | Manual traversal | `find()` method | `std::find()` |
| Reverse | 3-pointer technique | `reverse()` | `reverse()` |
| Sort | Merge sort (manual) | Implement yourself | `sort()` |
| Destroy | Traverse + `free` each | Destructor (RAII) | Automatic |
| Memory leaks? | If you forget `free` | No (destructor) | No (RAII) |

## Pros & Cons

### C Linked List
✅ Full understanding of how it works internally  
✅ No overhead — raw pointers  
✅ Customizable (intrusive lists, XOR lists, etc.)  
✅ Educational — fundamental DSA skill  
❌ Memory leaks if cleanup is missed  
❌ Dangling pointers on incorrect deletion  
❌ Must implement every operation from scratch  
❌ No type safety — usually uses `void*` for generic lists  

### C++ Custom LinkedList
✅ Encapsulated — users can't corrupt internal pointers  
✅ Template-based — works for any type  
✅ RAII — destructor prevents memory leaks  
✅ Operator overloading for clean printing  
❌ Still must implement all operations  
❌ Copy/move semantics need careful handling  

### C++ `std::list` (STL)
✅ **Production-ready** — thoroughly tested and optimized  
✅ Doubly-linked — O(1) insert/delete at both ends  
✅ `splice()` — O(1) move of elements between lists  
✅ Stable iterators — insertion/deletion doesn't invalidate others  
✅ Works with all STL algorithms  
❌ Cache-unfriendly (nodes scattered in memory)  
❌ Higher memory overhead (prev + next pointers)  
❌ **Usually slower than `vector`** due to cache misses  

## When to Use What

| Use Case | Recommendation |
|----------|---------------|
| Learning DSA | Implement in C first, then C++ class |
| Need fast insert/delete at arbitrary positions | `std::list` |
| Need fast random access | `std::vector` (not list!) |
| Competitive programming | `std::list` or `std::deque` |
| Embedded/kernel code | C linked list |

> **Important**: In practice, `std::vector` outperforms `std::list` in most scenarios due to cache locality, even for operations where list has better algorithmic complexity.
