/*
 * Arrays in C++
 * Demonstrates: std::array, std::vector, range-based for, algorithms
 */
#include <iostream>
#include <array>
#include <vector>
#include <algorithm>  // sort, reverse, max_element
#include <numeric>    // accumulate
using namespace std;

template <typename T>
void print_container(const T& container) {
    cout << "[";
    for (size_t i = 0; i < container.size(); i++) {
        cout << container[i];
        if (i < container.size() - 1) cout << ", ";
    }
    cout << "]" << endl;
}

int main() {
    // std::array — fixed size, but knows its own size
    cout << "=== std::array ===" << endl;
    array<int, 10> numbers = {64, 34, 25, 12, 22, 11, 90, 45, 78, 33};

    cout << "Original: ";
    print_container(numbers);

    // Algorithms work directly
    cout << "Max element: " << *max_element(numbers.begin(), numbers.end()) << endl;
    cout << "Sum: " << accumulate(numbers.begin(), numbers.end(), 0) << endl;

    // Reverse using STL algorithm
    reverse(numbers.begin(), numbers.end());
    cout << "Reversed: ";
    print_container(numbers);

    // Sort
    sort(numbers.begin(), numbers.end());
    cout << "Sorted: ";
    print_container(numbers);

    // 2D Array using nested std::array
    cout << "\n=== 2D Array (Matrix) ===" << endl;
    array<array<int, 3>, 3> matrix = {{
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }};

    // Range-based for loop — no index needed
    for (const auto& row : matrix) {
        for (const auto& elem : row) {
            cout << elem << " ";
        }
        cout << endl;
    }

    // std::vector — dynamic array (most commonly used)
    cout << "\n=== std::vector (Dynamic) ===" << endl;
    vector<int> dynamic_arr;  // No need to specify size upfront

    // Push elements — grows automatically
    for (int i = 1; i <= 5; i++) {
        dynamic_arr.push_back(i * 10);
    }
    cout << "After push_back: ";
    print_container(dynamic_arr);
    cout << "Size: " << dynamic_arr.size() << endl;
    cout << "Capacity: " << dynamic_arr.capacity() << endl;

    // Insert and erase
    dynamic_arr.insert(dynamic_arr.begin() + 2, 99);
    cout << "After insert 99 at index 2: ";
    print_container(dynamic_arr);

    dynamic_arr.erase(dynamic_arr.begin());
    cout << "After erase first: ";
    print_container(dynamic_arr);

    // C++11 initializer list
    vector<string> names = {"Alice", "Bob", "Charlie"};
    for (const auto& name : names) {
        cout << name << " ";
    }
    cout << endl;

    // No need to free — vector manages its own memory (RAII)
    return 0;
}
