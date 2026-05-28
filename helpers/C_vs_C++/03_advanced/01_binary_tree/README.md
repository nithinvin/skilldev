# Binary Tree — C vs C++

## Side-by-Side

| Operation | C (Manual BST) | C++ (Custom BST) | C++ (`std::set`/`std::map`) |
|-----------|----------------|-------------------|---------------------------|
| Insert | O(log n) avg | O(log n) avg | O(log n) guaranteed |
| Search | O(log n) avg | O(log n) avg | O(log n) guaranteed |
| Delete | O(log n) avg | O(log n) avg | O(log n) guaranteed |
| Traversal | Recursive functions | Returns `vector` | Range-based `for` |
| Balancing | ❌ (can degrade to O(n)) | ❌ | ✅ (Red-Black Tree) |
| Memory mgmt | Manual `free` | `unique_ptr` (auto) | Automatic |

## Pros & Cons

### C BST
✅ Full control over node structure  
✅ Educational — understand BST mechanics deeply  
✅ Can customize for specific use cases  
✅ No overhead from balancing  
❌ Can degrade to O(n) without balancing  
❌ Memory leaks if `tree_destroy` not called  
❌ Complex deletion logic  
❌ Must implement every operation from scratch  

### C++ Custom BST
✅ Encapsulated — clean API  
✅ `unique_ptr` prevents memory leaks  
✅ Returns structured data (`vector<int>`, `vector<vector<int>>`)  
✅ Template-ready for any comparable type  
❌ Still unbalanced  
❌ More code than using STL  

### C++ `std::set` / `std::map`
✅ **Self-balancing** (Red-Black Tree) — O(log n) guaranteed  
✅ `lower_bound`, `upper_bound` for range queries  
✅ Iteration always in sorted order  
✅ Production-ready, thread-safe for readers  
✅ `std::map` for key-value associations  
❌ Cannot control tree structure  
❌ No parent pointer access  
❌ Overhead from balancing on every insert  

## When to Use

| Scenario | Best Choice |
|----------|-------------|
| Learning trees/BST | Manual C implementation |
| Need sorted data + fast lookup | `std::set` |
| Key-value with sorted keys | `std::map` |
| Need custom traversals | Custom BST class |
| Frequency counting | `std::map<T, int>` |
| Competitive programming | `std::set` with `lower_bound` |
