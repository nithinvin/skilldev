# Hello World — C vs C++

## Side-by-Side

| Feature | C | C++ |
|---------|---|-----|
| Header | `#include <stdio.h>` | `#include <iostream>` |
| Output | `printf("text\n")` | `cout << "text" << endl` |
| Main signature | `int main(void)` | `int main()` |
| Namespace | Not applicable | `using namespace std;` |

## Key Differences

1. **I/O Mechanism**: C uses format strings (`%d`, `%s`), C++ uses stream insertion (`<<`)
2. **Type Safety**: `cout` is type-safe (no format mismatch bugs), `printf` is not
3. **Newline**: C uses `\n` in strings; C++ can use `endl` (which also flushes the buffer)

## Pros & Cons

### C
✅ Simpler, fewer abstractions  
✅ Slightly faster compilation  
✅ Format strings are compact for complex output  
❌ No type checking on format specifiers (`%d` with a string = undefined behavior)

### C++
✅ Type-safe output — compiler catches mismatches  
✅ Extensible — custom types can overload `<<`  
✅ No need to memorize format specifiers  
❌ `endl` flushes buffer (slower than `\n` in loops)  
❌ `using namespace std;` can cause name collisions in large projects
