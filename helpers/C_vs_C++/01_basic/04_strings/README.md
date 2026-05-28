# Strings — C vs C++

## Side-by-Side

| Operation | C | C++ |
|-----------|---|-----|
| Declare | `char s[50] = "hello"` | `string s = "hello"` |
| Length | `strlen(s)` | `s.length()` |
| Copy | `strcpy(dst, src)` | `dst = src` |
| Concatenate | `strcat(s1, s2)` | `s1 + s2` or `s1 += s2` |
| Compare | `strcmp(s1, s2)` | `s1 == s2`, `s1 < s2` |
| Find | `strstr(hay, needle)` | `s.find("needle")` |
| Substring | Manual pointer arithmetic | `s.substr(pos, len)` |
| Split | `strtok(s, delim)` (destructive) | `getline(ss, tok, delim)` (non-destructive) |

## Pros & Cons

### C Strings (`char[]` + `string.h`)
✅ No heap allocation for small fixed strings  
✅ Direct memory control — useful in embedded/OS development  
✅ Compatible with system calls and legacy APIs  
❌ **Buffer overflow** — #1 source of security vulnerabilities  
❌ Must track size manually  
❌ `strtok` destroys the original string  
❌ No operator support — must call functions for basic operations  
❌ Concatenation requires pre-allocated buffer  

### C++ Strings (`std::string`)
✅ **No buffer overflow** — grows automatically  
✅ Operators work naturally (`+`, `==`, `<`)  
✅ Rich method set: `find`, `replace`, `substr`, `insert`  
✅ Works with STL algorithms  
✅ Memory managed automatically  
❌ Heap allocation has overhead (SSO helps for short strings)  
❌ Passing by value copies the entire string (use `const string&`)  
❌ Converting to C-string requires `.c_str()`  

## Security Note

Buffer overflow in C strings is one of the most exploited vulnerabilities in history. C++ `std::string` eliminates this entire class of bugs. For any application handling user input, C++ strings are significantly safer.

## Performance Tip

```cpp
// Bad — creates temporary strings
string result = s1 + s2 + s3 + s4;

// Better — reserve and append
string result;
result.reserve(s1.size() + s2.size() + s3.size() + s4.size());
result += s1; result += s2; result += s3; result += s4;
```
