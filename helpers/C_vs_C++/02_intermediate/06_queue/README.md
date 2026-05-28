# Queue — C vs C++

## Side-by-Side

| Feature | C (Circular Array) | C (Linked List) | C++ `std::queue` | C++ `std::priority_queue` |
|---------|--------------------|-----------------|-----------------|-----------------------|
| Enqueue | O(1) | O(1) | O(1) | O(log n) |
| Dequeue | O(1) | O(1) | O(1) | O(log n) |
| Peek | O(1) | O(1) | O(1) | O(1) |
| Size limit | Fixed | Unlimited | Unlimited | Unlimited |
| Order | FIFO | FIFO | FIFO | By priority |
| Random access | ❌ | ❌ | ❌ | ❌ |

## Pros & Cons

### C Queue
✅ Complete control over implementation  
✅ Circular buffer is memory-efficient and cache-friendly  
✅ No hidden allocations in array version  
✅ Educational — understand the mechanics  
❌ Fixed size requires MAX constant or dynamic resizing  
❌ Must implement for each type  
❌ Priority queue requires implementing a heap from scratch  
❌ No standard library support  

### C++ Queue (`std::queue`, `std::deque`, `std::priority_queue`)
✅ `std::queue` — ready-to-use FIFO, adaptor over deque  
✅ `std::deque` — double-ended with random access  
✅ `std::priority_queue` — heap-based, logarithmic insert/extract  
✅ Template — works for any type  
✅ Custom comparators for priority ordering  
✅ No manual memory management  
❌ `std::queue` doesn't allow iteration (FIFO only)  
❌ `std::priority_queue` doesn't support decrease-key (Dijkstra limitation)  
❌ `std::deque` is slightly slower than `vector` for sequential access  

## STL Queue Variants

| Container | Use Case |
|-----------|----------|
| `std::queue<T>` | BFS, task scheduling, producer-consumer |
| `std::deque<T>` | Sliding window, double-ended operations |
| `std::priority_queue<T>` | Dijkstra, event scheduling, top-K problems |
| `std::priority_queue<T, vector<T>, greater<T>>` | Min-heap version |

## Common Patterns

```cpp
// BFS template
queue<int> q;
q.push(start);
while (!q.empty()) {
    auto current = q.front(); q.pop();
    // process current
    // q.push(neighbors);
}

// Level-order with level tracking
while (!q.empty()) {
    int levelSize = q.size();  // Key trick!
    for (int i = 0; i < levelSize; i++) {
        // process all nodes at this level
    }
}
```
