# Graph Algorithms — C vs C++

## Side-by-Side

| Feature | C | C++ |
|---------|---|-----|
| Adjacency list | Array of linked lists | `vector<vector<pair<int,int>>>` |
| Queue for BFS | Manual array queue | `std::queue` |
| Stack for DFS | Manual array stack | `std::stack` |
| Priority queue (Dijkstra) | Manual heap or array | `std::priority_queue` |
| Memory management | `malloc/free` for each node | Automatic (vector) |
| Code for BFS | ~40 lines | ~20 lines |
| Code for Dijkstra | ~80 lines | ~25 lines |

## Pros & Cons

### C Graph
✅ Full control over memory layout  
✅ Can optimize adjacency list for specific patterns  
✅ No overhead from STL containers  
✅ Better for understanding graph internals  
❌ Lots of boilerplate (malloc, free, linked lists)  
❌ Adjacency list needs manual memory cleanup  
❌ Must implement BFS queue, DFS stack manually  
❌ Priority queue for Dijkstra is complex to implement  

### C++ Graph
✅ `vector<vector<pair<int,int>>>` — one line for adjacency list  
✅ STL `queue`, `stack`, `priority_queue` — ready-to-use  
✅ Structured bindings: `auto [neighbor, weight] = ...`  
✅ `priority_queue` with `greater<>` for min-heap  
✅ Return `vector<int>` for results — no output parameters  
✅ Encapsulation in Graph class — clean reusable API  
❌ `priority_queue` doesn't support decrease-key  
❌ Vector of vectors has indirection overhead  

## Key STL Usage in Graph Algorithms

```cpp
// Adjacency list
vector<vector<pair<int, int>>> adj(n);  // adj[u] = {(v, w), ...}

// BFS
queue<int> q;

// DFS
stack<int> s;
// or recursion

// Dijkstra
priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;

// Visited set
vector<bool> visited(n, false);
// or unordered_set<int>

// Topological sort
vector<int> inDegree(n, 0);
```

## Algorithm Complexities

| Algorithm | Time | Space | Use Case |
|-----------|------|-------|----------|
| BFS | O(V + E) | O(V) | Shortest path (unweighted), level-order |
| DFS | O(V + E) | O(V) | Cycle detection, topological sort |
| Dijkstra | O((V+E) log V) | O(V) | Shortest path (weighted, no negative) |
| Topological Sort | O(V + E) | O(V) | Task scheduling, dependency resolution |
