/*
 * Templates in C++
 * Demonstrates: function templates, class templates, template specialization,
 *               variadic templates, concepts (C++20)
 */
#include <iostream>
#include <vector>
#include <string>
#include <type_traits>
#include <algorithm>
using namespace std;

// ===== Function Templates =====
template <typename T>
T maximum(T a, T b) {
    return (a > b) ? a : b;
}

// Multiple template parameters
template <typename T, typename U>
auto add(T a, U b) -> decltype(a + b) {
    return a + b;
}

// Template with constraint (C++20 concept alternative using SFINAE)
template <typename T>
typename enable_if<is_arithmetic<T>::value, T>::type
safe_divide(T a, T b) {
    if (b == 0) throw runtime_error("Division by zero!");
    return a / b;
}

// ===== Class Templates =====
template <typename T>
class DynamicArray {
private:
    vector<T> data;

public:
    void push_back(const T& value) { data.push_back(value); }
    void pop_back() { data.pop_back(); }
    T& operator[](size_t i) { return data[i]; }
    const T& operator[](size_t i) const { return data[i]; }
    size_t size() const { return data.size(); }
    bool empty() const { return data.empty(); }

    // Method template
    template <typename Func>
    void apply(Func f) {
        for (auto& elem : data) elem = f(elem);
    }

    // Print
    friend ostream& operator<<(ostream& os, const DynamicArray& arr) {
        os << "[";
        for (size_t i = 0; i < arr.size(); i++) {
            os << arr[i];
            if (i < arr.size() - 1) os << ", ";
        }
        os << "]";
        return os;
    }
};

// ===== Template Specialization =====
template <typename T>
class Printer {
public:
    static void print(const T& value) {
        cout << value;
    }
};

// Specialization for vector<T>
template <typename T>
class Printer<vector<T>> {
public:
    static void print(const vector<T>& vec) {
        cout << "{";
        for (size_t i = 0; i < vec.size(); i++) {
            Printer<T>::print(vec[i]);
            if (i < vec.size() - 1) cout << ", ";
        }
        cout << "}";
    }
};

// ===== Variadic Templates =====
// Base case
template <typename T>
T sum(T value) {
    return value;
}

// Recursive case
template <typename T, typename... Args>
T sum(T first, Args... rest) {
    return first + sum(rest...);
}

// Print any number of arguments
template <typename T>
void print_all(const T& value) {
    cout << value << endl;
}

template <typename T, typename... Args>
void print_all(const T& first, const Args&... rest) {
    cout << first << " ";
    print_all(rest...);
}

// ===== Pair template (like std::pair) =====
template <typename T1, typename T2>
struct Pair {
    T1 first;
    T2 second;

    Pair(const T1& f, const T2& s) : first(f), second(s) {}

    friend ostream& operator<<(ostream& os, const Pair& p) {
        os << "(" << p.first << ", " << p.second << ")";
        return os;
    }
};

// Template function to make pairs (like std::make_pair)
template <typename T1, typename T2>
Pair<T1, T2> make_my_pair(const T1& a, const T2& b) {
    return Pair<T1, T2>(a, b);
}

int main() {
    cout << "=== Templates in C++ ===" << endl;

    // Function templates
    cout << "\n--- Function Templates ---" << endl;
    cout << "max(10, 20) = " << maximum(10, 20) << endl;
    cout << "max(3.14, 2.71) = " << maximum(3.14, 2.71) << endl;
    cout << "max(\"apple\", \"banana\") = " << maximum(string("apple"), string("banana")) << endl;
    cout << "add(3, 4.5) = " << add(3, 4.5) << endl;
    cout << "safe_divide(10, 3) = " << safe_divide(10, 3) << endl;

    // Class templates
    cout << "\n--- Class Templates ---" << endl;
    DynamicArray<int> intArr;
    for (int i = 1; i <= 5; i++) intArr.push_back(i * 10);
    cout << "int array: " << intArr << endl;

    intArr.apply([](int x) { return x * 2; });
    cout << "After *2:  " << intArr << endl;

    DynamicArray<string> strArr;
    strArr.push_back("Hello");
    strArr.push_back("Template");
    strArr.push_back("World");
    cout << "string array: " << strArr << endl;

    // Template specialization
    cout << "\n--- Template Specialization ---" << endl;
    Printer<int>::print(42);
    cout << endl;
    Printer<string>::print("hello");
    cout << endl;
    vector<int> v = {1, 2, 3, 4, 5};
    Printer<vector<int>>::print(v);
    cout << endl;
    vector<vector<int>> vv = {{1, 2}, {3, 4}};
    Printer<vector<vector<int>>>::print(vv);
    cout << endl;

    // Variadic templates
    cout << "\n--- Variadic Templates ---" << endl;
    cout << "sum(1, 2, 3, 4, 5) = " << sum(1, 2, 3, 4, 5) << endl;
    cout << "sum(1.1, 2.2, 3.3) = " << sum(1.1, 2.2, 3.3) << endl;
    cout << "print_all: ";
    print_all(1, "hello", 3.14, 'x', "world");

    // Custom Pair
    cout << "\n--- Custom Pair Template ---" << endl;
    auto p1 = make_my_pair(string("Alice"), 95);
    auto p2 = make_my_pair(3.14, string("pi"));
    cout << "p1 = " << p1 << endl;
    cout << "p2 = " << p2 << endl;

    // Type traits (compile-time type inspection)
    cout << "\n--- Type Traits ---" << endl;
    cout << "is_integral<int>: " << boolalpha << is_integral<int>::value << endl;
    cout << "is_integral<double>: " << is_integral<double>::value << endl;
    cout << "is_same<int, int32_t>: " << is_same<int, int32_t>::value << endl;

    return 0;
}
