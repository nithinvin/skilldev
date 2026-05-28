/*
 * Functions in C++
 * Demonstrates: overloading, default args, references, lambdas, templates
 */
#include <iostream>
#include <vector>
#include <algorithm>
#include <functional>  // std::function
using namespace std;

// Function overloading — same name, different parameters
int add(int a, int b) {
    return a + b;
}

double add(double a, double b) {  // Same name! C++ allows this
    return a + b;
}

string add(const string& a, const string& b) {  // Works for strings too
    return a + b;
}

// Pass by reference — no pointer syntax needed
void swap(int& a, int& b) {
    int temp = a;
    a = b;
    b = temp;
}

// Default arguments
void print_line(const string& text, int width = 40, char fill = ' ') {
    cout << string(width - text.length(), fill) << text << endl;
}

// Templates — generic functions (covered more in advanced)
template <typename T>
T maximum(T a, T b) {
    return (a > b) ? a : b;
}

// Lambda functions (C++11) — inline anonymous functions
// Higher-order function using std::function
void apply(vector<int>& arr, function<int(int)> func) {
    for (auto& elem : arr) {
        elem = func(elem);
    }
}

int main() {
    cout << "=== Functions in C++ ===" << endl << endl;

    // Overloading in action
    cout << "add(3, 4) = " << add(3, 4) << endl;
    cout << "add(3.5, 4.2) = " << add(3.5, 4.2) << endl;
    cout << "add(\"Hello\", \" World\") = " << add("Hello"s, " World"s) << endl;

    // Pass by reference
    int x = 10, y = 20;
    cout << "\nBefore swap: x=" << x << ", y=" << y << endl;
    swap(x, y);  // No & needed at call site!
    cout << "After swap:  x=" << x << ", y=" << y << endl;

    // Default arguments
    cout << "\n--- Default Arguments ---" << endl;
    print_line("Right-aligned");          // uses default width=40, fill=' '
    print_line("Custom width", 20);       // uses default fill=' '
    print_line("Stars", 20, '*');         // all args specified

    // Templates
    cout << "\n--- Templates ---" << endl;
    cout << "max(10, 20) = " << maximum(10, 20) << endl;
    cout << "max(3.14, 2.71) = " << maximum(3.14, 2.71) << endl;
    cout << "max(\"apple\", \"banana\") = " << maximum("apple"s, "banana"s) << endl;

    // Lambda functions
    cout << "\n--- Lambdas ---" << endl;
    vector<int> arr = {1, 2, 3, 4, 5};

    cout << "Original: ";
    for (auto v : arr) cout << v << " ";

    // Lambda with capture
    int factor = 3;
    apply(arr, [factor](int x) { return x * factor; });
    cout << "\nMultiplied by " << factor << ": ";
    for (auto v : arr) cout << v << " ";

    apply(arr, [](int x) { return x * x; });
    cout << "\nSquared: ";
    for (auto v : arr) cout << v << " ";
    cout << endl;

    // STL algorithms with lambdas
    cout << "\n--- STL + Lambda ---" << endl;
    vector<int> nums = {5, 2, 8, 1, 9, 3, 7};
    
    // Sort descending
    sort(nums.begin(), nums.end(), [](int a, int b) { return a > b; });
    cout << "Sorted desc: ";
    for (auto v : nums) cout << v << " ";
    cout << endl;

    // Count elements > 5
    int count = count_if(nums.begin(), nums.end(), [](int x) { return x > 5; });
    cout << "Elements > 5: " << count << endl;

    return 0;
}
