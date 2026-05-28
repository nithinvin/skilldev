/*
 * Hash Table in C++
 * Demonstrates: unordered_map, unordered_set, custom hash, applications
 */
#include <iostream>
#include <unordered_map>
#include <unordered_set>
#include <map>
#include <string>
#include <vector>
#include <sstream>
#include <algorithm>
using namespace std;

// Custom hash function for a struct
struct Point {
    int x, y;
    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
};

struct PointHash {
    size_t operator()(const Point& p) const {
        return hash<int>()(p.x) ^ (hash<int>()(p.y) << 1);
    }
};

int main() {
    cout << "=== Hash Table in C++ ===" << endl;

    // ---- unordered_map (hash map) ----
    cout << "\n--- std::unordered_map ---" << endl;
    unordered_map<string, int> grades;

    // Insert
    grades["Alice"] = 95;
    grades["Bob"] = 87;
    grades["Charlie"] = 92;
    grades["Diana"] = 88;
    grades["Eve"] = 91;
    grades.insert({"Frank", 85});  // Another way to insert

    // Print all
    cout << "All grades:" << endl;
    for (const auto& [name, grade] : grades) {
        cout << "  " << name << ": " << grade << endl;
    }

    // Lookup — O(1) average
    cout << "\nLookup 'Bob': ";
    if (auto it = grades.find("Bob"); it != grades.end())
        cout << "Found, value = " << it->second << endl;
    else
        cout << "Not found" << endl;

    cout << "Lookup 'Zara': ";
    if (grades.count("Zara"))
        cout << "Found" << endl;
    else
        cout << "Not found" << endl;

    // Update
    grades["Bob"] = 90;
    cout << "After update, Bob = " << grades["Bob"] << endl;

    // Delete
    grades.erase("Charlie");
    cout << "\nAfter erasing 'Charlie':" << endl;
    for (const auto& [name, grade] : grades)
        cout << "  " << name << ": " << grade << endl;

    // Size and bucket info
    cout << "\nSize: " << grades.size() << endl;
    cout << "Bucket count: " << grades.bucket_count() << endl;
    cout << "Load factor: " << grades.load_factor() << endl;

    // ---- unordered_set ----
    cout << "\n--- std::unordered_set ---" << endl;
    unordered_set<int> numbers = {5, 3, 8, 1, 9, 3, 5, 1};  // Duplicates removed
    cout << "Set: ";
    for (int n : numbers) cout << n << " ";
    cout << "(size=" << numbers.size() << ")" << endl;

    numbers.insert(7);
    numbers.erase(3);
    cout << "After insert 7, erase 3: ";
    for (int n : numbers) cout << n << " ";
    cout << endl;

    cout << "Contains 8? " << (numbers.count(8) ? "Yes" : "No") << endl;

    // ---- Application: Word frequency ----
    cout << "\n--- Word Frequency Counter ---" << endl;
    string text = "the cat sat on the mat the cat likes the mat";
    unordered_map<string, int> freq;

    istringstream iss(text);
    string word;
    while (iss >> word) {
        freq[word]++;  // One line! Compare to C version
    }

    // Sort by frequency for display
    vector<pair<string, int>> sorted_freq(freq.begin(), freq.end());
    sort(sorted_freq.begin(), sorted_freq.end(),
         [](const auto& a, const auto& b) { return a.second > b.second; });

    for (const auto& [w, count] : sorted_freq) {
        cout << "  " << w << ": " << count << endl;
    }

    // ---- Application: Two Sum problem ----
    cout << "\n--- Two Sum (Classic Interview Problem) ---" << endl;
    vector<int> nums = {2, 7, 11, 15};
    int target = 9;

    unordered_map<int, int> seen;  // value -> index
    for (int i = 0; i < (int)nums.size(); i++) {
        int complement = target - nums[i];
        if (seen.count(complement)) {
            cout << "  Indices: [" << seen[complement] << ", " << i << "]"
                 << " (values " << nums[seen[complement]] << " + " << nums[i]
                 << " = " << target << ")" << endl;
            break;
        }
        seen[nums[i]] = i;
    }

    // ---- Custom hash for user-defined type ----
    cout << "\n--- Custom Hash (Point struct) ---" << endl;
    unordered_set<Point, PointHash> visited;
    visited.insert({0, 0});
    visited.insert({1, 2});
    visited.insert({3, 4});
    visited.insert({1, 2});  // Duplicate — ignored

    cout << "Visited points (" << visited.size() << "):" << endl;
    for (const auto& p : visited) {
        cout << "  (" << p.x << ", " << p.y << ")" << endl;
    }

    // ---- unordered_map vs map ----
    cout << "\n--- unordered_map vs map ---" << endl;
    cout << "unordered_map: O(1) avg lookup, unordered" << endl;
    cout << "map:           O(log n) lookup, sorted by key" << endl;

    return 0;
}
