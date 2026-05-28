/*
 * Linked List in C++
 * Demonstrates: custom linked list class + std::list comparison
 */
#include <iostream>
#include <list>       // STL doubly-linked list
#include <algorithm>
using namespace std;

// Custom implementation using classes
template <typename T>
class LinkedList {
private:
    struct Node {
        T data;
        Node* next;
        Node(const T& d) : data(d), next(nullptr) {}
    };

    Node* head;
    int count;

public:
    LinkedList() : head(nullptr), count(0) {}

    // Destructor — automatic cleanup
    ~LinkedList() {
        Node* current = head;
        while (current) {
            Node* next = current->next;
            delete current;
            current = next;
        }
    }

    // Disable copy (or implement properly)
    LinkedList(const LinkedList&) = delete;
    LinkedList& operator=(const LinkedList&) = delete;

    void push_front(const T& data) {
        Node* node = new Node(data);
        node->next = head;
        head = node;
        count++;
    }

    void push_back(const T& data) {
        Node* node = new Node(data);
        if (!head) {
            head = node;
        } else {
            Node* current = head;
            while (current->next) current = current->next;
            current->next = node;
        }
        count++;
    }

    bool remove(const T& data) {
        if (!head) return false;
        if (head->data == data) {
            Node* temp = head;
            head = head->next;
            delete temp;
            count--;
            return true;
        }
        Node* current = head;
        while (current->next && current->next->data != data)
            current = current->next;
        if (!current->next) return false;
        Node* temp = current->next;
        current->next = temp->next;
        delete temp;
        count--;
        return true;
    }

    bool find(const T& data) const {
        Node* current = head;
        while (current) {
            if (current->data == data) return true;
            current = current->next;
        }
        return false;
    }

    void reverse() {
        Node *prev = nullptr, *current = head, *next = nullptr;
        while (current) {
            next = current->next;
            current->next = prev;
            prev = current;
            current = next;
        }
        head = prev;
    }

    int size() const { return count; }

    // Stream output operator
    friend ostream& operator<<(ostream& os, const LinkedList& list) {
        os << "[";
        Node* current = list.head;
        while (current) {
            os << current->data;
            if (current->next) os << " -> ";
            current = current->next;
        }
        os << "] (size=" << list.count << ")";
        return os;
    }
};

int main() {
    cout << "=== Linked List in C++ ===" << endl;

    // ---- Custom Implementation ----
    cout << "\n--- Custom LinkedList<int> ---" << endl;
    {
        LinkedList<int> list;

        list.push_back(10);
        list.push_back(20);
        list.push_back(30);
        list.push_front(5);
        list.push_front(1);
        cout << "After insertions: " << list << endl;

        cout << "Search 20: " << (list.find(20) ? "Found" : "Not found") << endl;
        cout << "Search 99: " << (list.find(99) ? "Found" : "Not found") << endl;

        list.remove(20);
        cout << "After deleting 20: " << list << endl;

        list.remove(1);
        cout << "After deleting 1: " << list << endl;

        list.reverse();
        cout << "After reverse: " << list << endl;
    }
    cout << "List destroyed automatically (RAII)" << endl;

    // ---- STL std::list (doubly-linked) ----
    cout << "\n--- std::list (STL) ---" << endl;
    list<int> stl_list = {10, 20, 30, 40, 50};

    // Print
    cout << "Initial: ";
    for (auto v : stl_list) cout << v << " ";
    cout << endl;

    // Insert
    stl_list.push_front(5);
    stl_list.push_back(60);

    // Remove by value
    stl_list.remove(30);
    cout << "After push_front(5), push_back(60), remove(30): ";
    for (auto v : stl_list) cout << v << " ";
    cout << endl;

    // Sort (std::list has its own sort — not std::sort)
    stl_list.sort();
    cout << "Sorted: ";
    for (auto v : stl_list) cout << v << " ";
    cout << endl;

    // Reverse
    stl_list.reverse();
    cout << "Reversed: ";
    for (auto v : stl_list) cout << v << " ";
    cout << endl;

    // Unique (remove consecutive duplicates)
    stl_list.push_back(5);
    stl_list.push_back(5);
    stl_list.sort();
    stl_list.unique();
    cout << "After unique: ";
    for (auto v : stl_list) cout << v << " ";
    cout << endl;

    // Size
    cout << "Size: " << stl_list.size() << endl;

    // Find using algorithm
    auto it = find(stl_list.begin(), stl_list.end(), 40);
    if (it != stl_list.end())
        cout << "Found 40 in list" << endl;

    // Splice, merge — advanced operations available
    cout << "\n--- std::list with strings ---" << endl;
    list<string> names = {"Charlie", "Alice", "Bob", "Diana"};
    names.sort();
    for (const auto& n : names) cout << n << " ";
    cout << endl;

    return 0;
}
