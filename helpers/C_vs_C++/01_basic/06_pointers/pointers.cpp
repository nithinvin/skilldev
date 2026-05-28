/*
 * Pointers and References in C++
 * Demonstrates: references, smart pointers, nullptr, modern alternatives
 */
#include <iostream>
#include <memory>   // smart pointers
#include <vector>
using namespace std;

// Pass by reference — clean syntax, no null possible
void swap_ref(int& a, int& b) {
    int temp = a;
    a = b;
    b = temp;
}

// Const reference — read-only, no copy
void print_vector(const vector<int>& v) {
    for (const auto& elem : v) {
        cout << elem << " ";
    }
    cout << endl;
}

// Smart pointer factory
unique_ptr<int[]> create_array(int size) {
    auto arr = make_unique<int[]>(size);
    for (int i = 0; i < size; i++) {
        arr[i] = (i + 1) * 100;
    }
    return arr;  // Ownership transferred to caller
}

class Resource {
public:
    string name;
    Resource(const string& n) : name(n) {
        cout << "  [Resource '" << name << "' created]" << endl;
    }
    ~Resource() {
        cout << "  [Resource '" << name << "' destroyed]" << endl;
    }
    void use() { cout << "  Using resource: " << name << endl; }
};

int main() {
    cout << "=== Pointers & References in C++ ===" << endl << endl;

    // References — alias for existing variable
    int x = 42;
    int& ref = x;  // ref IS x (not a copy, not a pointer)

    cout << "x = " << x << ", ref = " << ref << endl;
    ref = 100;
    cout << "After ref = 100: x = " << x << endl;
    cout << "Address: &x = " << &x << ", &ref = " << &ref << " (same!)" << endl;

    // Pass by reference
    int a = 10, b = 20;
    cout << "\nBefore swap: a=" << a << ", b=" << b << endl;
    swap_ref(a, b);
    cout << "After swap:  a=" << a << ", b=" << b << endl;

    // nullptr (C++11) — replaces NULL
    int* ptr = nullptr;  // Type-safe null
    if (ptr == nullptr) {
        cout << "\nptr is null" << endl;
    }

    // Raw pointers still work (but prefer smart pointers)
    ptr = &x;
    cout << "*ptr = " << *ptr << endl;

    // unique_ptr — single ownership, auto-deleted
    cout << "\n--- unique_ptr (Single Ownership) ---" << endl;
    {
        unique_ptr<Resource> res = make_unique<Resource>("FileHandle");
        res->use();
        // No delete needed! Destroyed automatically at end of scope
    }
    cout << "  (Scope ended — resource auto-freed)" << endl;

    // unique_ptr with arrays
    cout << "\n--- unique_ptr Array ---" << endl;
    auto arr = create_array(5);
    cout << "Dynamic array: ";
    for (int i = 0; i < 5; i++) cout << arr[i] << " ";
    cout << endl;
    // No free/delete needed!

    // shared_ptr — multiple owners, reference counted
    cout << "\n--- shared_ptr (Shared Ownership) ---" << endl;
    shared_ptr<Resource> shared1 = make_shared<Resource>("Database");
    cout << "  ref_count = " << shared1.use_count() << endl;
    {
        shared_ptr<Resource> shared2 = shared1;  // Shares ownership
        cout << "  ref_count = " << shared1.use_count() << endl;
        shared2->use();
    }
    cout << "  ref_count = " << shared1.use_count() << " (shared2 out of scope)" << endl;
    // Resource destroyed when last shared_ptr goes away

    // weak_ptr — non-owning observer (breaks circular references)
    cout << "\n--- weak_ptr ---" << endl;
    weak_ptr<Resource> observer = shared1;
    if (auto locked = observer.lock()) {
        locked->use();
    }

    cout << "\n--- End of main ---" << endl;
    return 0;
}
