# C vs C++ — Side-by-Side Comparison

A comprehensive collection of programs demonstrating how the **same functionality** is implemented in C and C++. Designed for a CSE student who has completed Year 1 (Python, DSA, OOP, C, C++).

## Directory Structure

```
├── 01_basic/          — Fundamentals: I/O, arrays, strings, functions, pointers
├── 02_intermediate/   — Structs vs Classes, dynamic memory, linked lists, stacks, queues
├── 03_advanced/       — Trees, graphs, hash tables, STL, templates, RAII, error handling
```

## How to Use

Each topic folder contains:
- `*.c` — The C implementation
- `*.cpp` — The C++ implementation
- `README.md` — Explanation with pros/cons comparison

## Compile & Run

```bash
# C
gcc -o program program.c -Wall -Wextra
./program

# C++
g++ -o program program.cpp -Wall -Wextra -std=c++17
./program
```

## Key Differences at a Glance

| Aspect | C | C++ |
|--------|---|-----|
| Paradigm | Procedural | Multi-paradigm (OOP, Generic, Procedural) |
| Memory | `malloc/free` | `new/delete`, smart pointers, RAII |
| Data Structures | Manual implementation | STL (vector, map, set, etc.) |
| Error Handling | Return codes, `errno` | Exceptions (`try/catch`) |
| Strings | `char[]`, `string.h` | `std::string` |
| I/O | `printf/scanf` | `cout/cin` + streams |
| Generics | `void*`, macros | Templates |
| Encapsulation | Conventions only | `class`, access specifiers |

## Progression

- **Basic**: Core syntax differences — where C++ adds convenience
- **Intermediate**: OOP, manual data structures in C vs class-based in C++
- **Advanced**: STL power, templates, RAII, and real-world patterns
