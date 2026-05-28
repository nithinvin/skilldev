/*
 * Strings in C++
 * Demonstrates: std::string, methods, string_view, modern features
 */
#include <iostream>
#include <string>
#include <algorithm>
#include <sstream>    // stringstream for splitting
#include <vector>
using namespace std;

int main() {
    cout << "=== String Operations in C++ ===" << endl << endl;

    // std::string — dynamic, safe, feature-rich
    string greeting = "Hello";
    string name = "World";

    cout << "greeting = \"" << greeting << "\"" << endl;
    cout << "Length: " << greeting.length() << endl;  // or .size()

    // Concatenation — just use +
    string result = greeting + ", " + name + "!";
    cout << "Concatenated: \"" << result << "\"" << endl;

    // Comparison — use ==, <, >
    string s1 = "apple";
    string s2 = "banana";
    if (s1 < s2)
        cout << "\"" << s1 << "\" comes before \"" << s2 << "\"" << endl;
    else if (s1 > s2)
        cout << "\"" << s1 << "\" comes after \"" << s2 << "\"" << endl;
    else
        cout << "\"" << s1 << "\" equals \"" << s2 << "\"" << endl;

    // Substring search
    string haystack = "Data Structures and Algorithms";
    size_t pos = haystack.find("Struct");
    if (pos != string::npos)
        cout << "Found 'Struct' at position: " << pos << endl;

    // Substring extraction
    string sub = haystack.substr(0, 4);  // "Data"
    cout << "Substring: \"" << sub << "\"" << endl;

    // Replace
    string text = "I love C programming";
    text.replace(text.find("C"), 1, "C++");
    cout << "After replace: \"" << text << "\"" << endl;

    // Transform to uppercase using algorithm
    string sentence = "hello world 123";
    cout << "\nOriginal: \"" << sentence << "\"" << endl;

    string upper = sentence;
    transform(upper.begin(), upper.end(), upper.begin(), ::toupper);
    cout << "Uppercase: \"" << upper << "\"" << endl;

    // Splitting using stringstream
    string csv = "VIT,Chennai,CSE,2024";
    cout << "\nTokenizing \"" << csv << "\":" << endl;
    stringstream ss(csv);
    string token;
    while (getline(ss, token, ',')) {
        cout << "  -> " << token << endl;
    }
    // Original string is NOT modified

    // No buffer overflow — string grows as needed
    string safe;
    safe += "This can be as long as you want! ";
    safe += "No buffer overflow possible.";
    cout << "\nSafe string: \"" << safe << "\"" << endl;
    cout << "Length: " << safe.length() << ", Capacity: " << safe.capacity() << endl;

    // C++11: Raw string literals
    string path = R"(C:\Users\student\documents)";  // no need to escape backslashes
    cout << "\nRaw string: " << path << endl;

    // C++17: string_view (non-owning, zero-copy reference)
    // string_view sv = "This doesn't allocate memory";

    return 0;
}
