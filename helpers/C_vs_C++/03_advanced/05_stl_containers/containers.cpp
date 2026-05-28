/*
 * STL Containers in C++
 * Demonstrates: vector, set, map, unordered_map, deque, priority_queue
 * and their algorithms
 */
#include <iostream>
#include <vector>
#include <set>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <deque>
#include <queue>
#include <stack>
#include <algorithm>
#include <numeric>
#include <string>
using namespace std;

int main() {
    cout << "=== STL Containers in C++ ===" << endl;

    // ===== std::vector =====
    cout << "\n========== std::vector ==========" << endl;
    vector<int> v = {5, 3, 8, 1, 9, 2, 7};

    // Algorithms
    sort(v.begin(), v.end());
    cout << "Sorted: ";
    for (auto x : v) cout << x << " ";
    cout << endl;

    // Binary search (on sorted vector)
    cout << "Contains 8? " << boolalpha << binary_search(v.begin(), v.end(), 8) << endl;

    // Lower/upper bound
    auto lb = lower_bound(v.begin(), v.end(), 5);
    cout << "Lower bound of 5: index " << (lb - v.begin()) << ", value " << *lb << endl;

    // Accumulate
    int sum = accumulate(v.begin(), v.end(), 0);
    cout << "Sum: " << sum << ", Count: " << v.size() << endl;

    // Remove-erase idiom
    v.erase(remove_if(v.begin(), v.end(), [](int x) { return x > 7; }), v.end());
    cout << "After removing > 7: ";
    for (auto x : v) cout << x << " ";
    cout << endl;

    // ===== std::set =====
    cout << "\n========== std::set ==========" << endl;
    set<int> s = {5, 3, 8, 1, 9, 3, 5, 7};  // Duplicates removed, sorted
    cout << "Set: ";
    for (auto x : s) cout << x << " ";
    cout << "(size=" << s.size() << ")" << endl;

    s.insert(6);
    s.erase(3);
    cout << "After insert 6, erase 3: ";
    for (auto x : s) cout << x << " ";
    cout << endl;

    // Range-based operations
    auto it = s.lower_bound(5);
    cout << "Elements >= 5: ";
    for (; it != s.end(); ++it) cout << *it << " ";
    cout << endl;

    // ===== std::map =====
    cout << "\n========== std::map ==========" << endl;
    map<string, int> grades = {
        {"Alice", 95}, {"Bob", 87}, {"Charlie", 92}
    };

    grades["Diana"] = 88;  // Insert
    grades["Bob"] = 90;    // Update

    // Structured bindings (C++17)
    for (const auto& [name, grade] : grades) {
        cout << "  " << name << ": " << grade << endl;
    }

    // Find
    if (auto it = grades.find("Charlie"); it != grades.end()) {
        cout << "Found Charlie: " << it->second << endl;
    }

    // ===== std::unordered_map =====
    cout << "\n========== std::unordered_map ==========" << endl;
    unordered_map<string, vector<string>> courses;
    courses["CSE"] = {"DSA", "OOP", "DBMS", "OS"};
    courses["ECE"] = {"Signals", "VLSI", "Embedded"};

    for (const auto& [dept, subjects] : courses) {
        cout << dept << ": ";
        for (const auto& s : subjects) cout << s << " ";
        cout << endl;
    }

    // ===== std::deque =====
    cout << "\n========== std::deque ==========" << endl;
    deque<int> dq;
    dq.push_front(1);
    dq.push_back(2);
    dq.push_front(0);
    dq.push_back(3);
    cout << "Deque: ";
    for (auto x : dq) cout << x << " ";
    cout << endl;
    cout << "Random access: dq[2] = " << dq[2] << endl;

    // ===== std::priority_queue =====
    cout << "\n========== std::priority_queue ==========" << endl;
    priority_queue<int> maxPQ;
    for (int x : {3, 1, 4, 1, 5, 9, 2, 6}) maxPQ.push(x);
    cout << "Max-heap order: ";
    while (!maxPQ.empty()) { cout << maxPQ.top() << " "; maxPQ.pop(); }
    cout << endl;

    // ===== Combining containers =====
    cout << "\n========== Practical: Group Anagrams ==========" << endl;
    vector<string> words = {"eat", "tea", "tan", "ate", "nat", "bat"};
    unordered_map<string, vector<string>> anagrams;

    for (const auto& word : words) {
        string key = word;
        sort(key.begin(), key.end());
        anagrams[key].push_back(word);
    }

    for (const auto& [key, group] : anagrams) {
        cout << "  [";
        for (size_t i = 0; i < group.size(); i++) {
            cout << group[i];
            if (i < group.size() - 1) cout << ", ";
        }
        cout << "]" << endl;
    }

    // ===== Container complexity summary =====
    cout << "\n========== Complexity Summary ==========" << endl;
    cout << "Container          | Insert   | Lookup   | Delete   | Ordered?" << endl;
    cout << "-------------------|----------|----------|----------|--------" << endl;
    cout << "vector             | O(1)*    | O(1)idx  | O(n)     | By index" << endl;
    cout << "deque              | O(1)ends | O(1)idx  | O(n)mid  | By index" << endl;
    cout << "list               | O(1)     | O(n)     | O(1)     | Insertion" << endl;
    cout << "set/map            | O(log n) | O(log n) | O(log n) | Sorted" << endl;
    cout << "unordered_set/map  | O(1)*    | O(1)*    | O(1)*    | No" << endl;
    cout << "priority_queue     | O(log n) | O(1)top  | O(log n) | By priority" << endl;
    cout << "* = amortized" << endl;

    return 0;
}
