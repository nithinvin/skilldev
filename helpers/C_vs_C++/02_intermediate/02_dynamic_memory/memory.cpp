/*
 * Dynamic Memory in C++
 * Demonstrates: new/delete, smart pointers, RAII, vector as dynamic array
 */
#include <iostream>
#include <memory>
#include <vector>
#include <string>
using namespace std;

// RAII-based dynamic string (but std::string already does this!)
class DynamicString {
private:
    string data;  // std::string handles all memory internally

public:
    DynamicString() = default;

    void append(const string& text) {
        data += text;  // Automatically grows
    }

    size_t length() const { return data.length(); }
    size_t capacity() const { return data.capacity(); }
    const string& str() const { return data; }

    // No destructor needed — string manages itself (Rule of Zero)
};

// RAII wrapper for a resource (demonstrating the pattern)
class Buffer {
private:
    unique_ptr<int[]> data;
    size_t size_;

public:
    Buffer(size_t n) : data(make_unique<int[]>(n)), size_(n) {
        cout << "  Buffer(" << n << ") allocated" << endl;
    }
    // No destructor needed — unique_ptr handles cleanup

    int& operator[](size_t i) { return data[i]; }
    const int& operator[](size_t i) const { return data[i]; }
    size_t size() const { return size_; }
};

int main() {
    cout << "=== Dynamic Memory in C++ ===" << endl << endl;

    // new/delete (avoid in modern C++ — use smart pointers)
    cout << "--- new/delete (legacy style) ---" << endl;
    int* ptr = new int(42);
    cout << "new'd value: " << *ptr << endl;
    delete ptr;
    ptr = nullptr;

    // Smart pointers — the modern way
    cout << "\n--- unique_ptr ---" << endl;
    {
        auto uptr = make_unique<int>(42);
        cout << "unique_ptr value: " << *uptr << endl;
        // Automatically deleted at end of scope
    }
    cout << "(auto-deleted)" << endl;

    // Vector as dynamic array (replaces malloc/realloc)
    cout << "\n--- vector (replaces malloc/realloc) ---" << endl;
    vector<int> arr;
    arr.reserve(5);  // Pre-allocate (like initial malloc)

    for (int i = 0; i < 5; i++) arr.push_back(i * 10);
    cout << "Initial (" << arr.size() << " elements): ";
    for (auto v : arr) cout << v << " ";
    cout << endl;

    // Grow — no realloc needed!
    for (int i = 5; i < 10; i++) arr.push_back(i * 10);
    cout << "After growth (" << arr.size() << " elements): ";
    for (auto v : arr) cout << v << " ";
    cout << "\nCapacity: " << arr.capacity() << endl;

    // Dynamic string — trivial in C++
    cout << "\n--- Dynamic String (std::string) ---" << endl;
    DynamicString ds;
    ds.append("Hello");
    ds.append(", ");
    ds.append("Dynamic");
    ds.append(" World!");
    cout << "String: \"" << ds.str() << "\" (len=" << ds.length()
         << ", cap=" << ds.capacity() << ")" << endl;

    // 2D Dynamic array using vector
    cout << "\n--- 2D Dynamic Array (vector<vector>) ---" << endl;
    int rows = 3, cols = 4;
    vector<vector<int>> matrix(rows, vector<int>(cols, 0));

    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            matrix[i][j] = i * cols + j;

    for (const auto& row : matrix) {
        for (auto val : row)
            cout << val << "\t";
        cout << endl;
    }
    // No free needed — vector handles everything

    // RAII Buffer class
    cout << "\n--- RAII Buffer ---" << endl;
    {
        Buffer buf(10);
        for (size_t i = 0; i < buf.size(); i++)
            buf[i] = i * i;

        cout << "  Buffer contents: ";
        for (size_t i = 0; i < buf.size(); i++)
            cout << buf[i] << " ";
        cout << endl;
    }
    cout << "  (Buffer auto-freed at scope exit)" << endl;

    return 0;
}
