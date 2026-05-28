# Advanced Level — C vs C++

These programs demonstrate advanced data structures, STL mastery, and modern C++ features.

| # | Topic | Key Difference |
|---|-------|---------------|
| 1 | Binary Tree | Manual tree + traversals vs class-based with iterators |
| 2 | Hash Table | Open addressing/chaining in C vs `unordered_map`/`unordered_set` |
| 3 | Sorting | qsort + function pointers vs `std::sort` + lambdas |
| 4 | Graph (BFS/DFS) | Adjacency matrix + manual queue vs adjacency list + STL |
| 5 | STL Containers | Manual C implementations vs vector/map/set/unordered_map |
| 6 | Templates & Generics | `void*` + macros vs type-safe templates |
| 7 | Error Handling | errno/return codes vs exceptions |
| 8 | RAII & Resources | goto-cleanup vs destructors + smart pointers |

## Summary

At the advanced level, C++ demonstrates its full power: **STL containers** replace hundreds of lines of manual code, **templates** provide zero-cost abstractions, **RAII** eliminates resource leaks, and **exceptions** simplify error handling. However, C retains advantages in embedded systems, operating systems, and situations requiring ABI stability.
