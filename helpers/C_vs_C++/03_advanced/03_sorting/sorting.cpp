/*
 * Sorting in C++
 * Demonstrates: std::sort, custom comparators, lambdas, partial_sort, nth_element
 */
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include <numeric>    // iota
#include <random>
using namespace std;

struct Student {
    string name;
    int score;
    int age;
};

ostream& operator<<(ostream& os, const Student& s) {
    os << s.name << " (score=" << s.score << ", age=" << s.age << ")";
    return os;
}

int main() {
    cout << "=== Sorting in C++ ===" << endl;

    // Basic sort — O(n log n) guaranteed (IntroSort)
    cout << "\n--- std::sort ---" << endl;
    vector<int> arr = {64, 34, 25, 12, 22, 11, 90};

    cout << "Before: ";
    for (auto v : arr) cout << v << " ";
    cout << endl;

    sort(arr.begin(), arr.end());
    cout << "Ascending: ";
    for (auto v : arr) cout << v << " ";
    cout << endl;

    sort(arr.begin(), arr.end(), greater<int>());
    cout << "Descending: ";
    for (auto v : arr) cout << v << " ";
    cout << endl;

    // Sort with lambda comparator
    cout << "\n--- Lambda Comparators ---" << endl;
    vector<string> words = {"banana", "apple", "cherry", "date", "elderberry"};

    // Sort by length
    sort(words.begin(), words.end(),
         [](const string& a, const string& b) { return a.length() < b.length(); });
    cout << "By length: ";
    for (const auto& w : words) cout << w << " ";
    cout << endl;

    // Sort alphabetically (default)
    sort(words.begin(), words.end());
    cout << "Alphabetical: ";
    for (const auto& w : words) cout << w << " ";
    cout << endl;

    // Sorting structs with multiple criteria
    cout << "\n--- Sorting Structs ---" << endl;
    vector<Student> students = {
        {"Charlie", 85, 20},
        {"Alice", 92, 19},
        {"Bob", 78, 21},
        {"Diana", 95, 19},
        {"Eve", 88, 20}
    };

    // Sort by score descending
    sort(students.begin(), students.end(),
         [](const Student& a, const Student& b) { return a.score > b.score; });
    cout << "By score (desc):" << endl;
    for (const auto& s : students) cout << "  " << s << endl;

    // Multi-criteria: by age, then by score
    sort(students.begin(), students.end(),
         [](const Student& a, const Student& b) {
             if (a.age != b.age) return a.age < b.age;
             return a.score > b.score;
         });
    cout << "\nBy age, then score:" << endl;
    for (const auto& s : students) cout << "  " << s << endl;

    // Stable sort — preserves relative order of equal elements
    cout << "\n--- stable_sort ---" << endl;
    stable_sort(students.begin(), students.end(),
                [](const Student& a, const Student& b) { return a.age < b.age; });
    cout << "Stable sort by age:" << endl;
    for (const auto& s : students) cout << "  " << s << endl;

    // partial_sort — sort only first K elements
    cout << "\n--- partial_sort (Top 3) ---" << endl;
    vector<int> nums = {9, 3, 7, 1, 5, 8, 2, 6, 4};
    partial_sort(nums.begin(), nums.begin() + 3, nums.end());
    cout << "Top 3 smallest: ";
    for (int i = 0; i < 3; i++) cout << nums[i] << " ";
    cout << endl;

    // nth_element — find kth smallest in O(n)
    cout << "\n--- nth_element (Median) ---" << endl;
    vector<int> data = {9, 3, 7, 1, 5, 8, 2, 6, 4};
    int mid = data.size() / 2;
    nth_element(data.begin(), data.begin() + mid, data.end());
    cout << "Median (middle element): " << data[mid] << endl;

    // is_sorted check
    cout << "\n--- Utility Functions ---" << endl;
    vector<int> sorted_v = {1, 2, 3, 4, 5};
    vector<int> unsorted_v = {1, 3, 2, 4, 5};
    cout << "sorted_v is sorted: " << boolalpha << is_sorted(sorted_v.begin(), sorted_v.end()) << endl;
    cout << "unsorted_v is sorted: " << is_sorted(unsorted_v.begin(), unsorted_v.end()) << endl;

    // Sort indices (useful pattern)
    cout << "\n--- Sort Indices Pattern ---" << endl;
    vector<int> values = {30, 10, 50, 20, 40};
    vector<int> indices(values.size());
    iota(indices.begin(), indices.end(), 0);  // 0, 1, 2, 3, 4

    sort(indices.begin(), indices.end(),
         [&values](int a, int b) { return values[a] < values[b]; });

    cout << "Values sorted by index: ";
    for (int i : indices) cout << values[i] << " ";
    cout << endl;
    cout << "Original indices: ";
    for (int i : indices) cout << i << " ";
    cout << endl;

    return 0;
}
