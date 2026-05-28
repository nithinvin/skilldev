/*
 * Binary Search Tree in C++
 * Demonstrates: class-based BST, std::set/map as balanced BST
 */
#include <iostream>
#include <queue>
#include <set>
#include <map>
#include <vector>
#include <memory>
#include <functional>
using namespace std;

// Custom BST implementation using smart pointers
class BST {
private:
    struct Node {
        int data;
        unique_ptr<Node> left;
        unique_ptr<Node> right;
        Node(int d) : data(d) {}
    };

    unique_ptr<Node> root;

    void insert(unique_ptr<Node>& node, int data) {
        if (!node) {
            node = make_unique<Node>(data);
        } else if (data < node->data) {
            insert(node->left, data);
        } else if (data > node->data) {
            insert(node->right, data);
        }
    }

    Node* findMin(Node* node) const {
        while (node->left) node = node->left.get();
        return node;
    }

    void remove(unique_ptr<Node>& node, int data) {
        if (!node) return;
        if (data < node->data) {
            remove(node->left, data);
        } else if (data > node->data) {
            remove(node->right, data);
        } else {
            if (!node->left) {
                node = move(node->right);
            } else if (!node->right) {
                node = move(node->left);
            } else {
                Node* successor = findMin(node->right.get());
                node->data = successor->data;
                remove(node->right, successor->data);
            }
        }
    }

    void inorder(const unique_ptr<Node>& node, vector<int>& result) const {
        if (!node) return;
        inorder(node->left, result);
        result.push_back(node->data);
        inorder(node->right, result);
    }

    void preorder(const unique_ptr<Node>& node, vector<int>& result) const {
        if (!node) return;
        result.push_back(node->data);
        preorder(node->left, result);
        preorder(node->right, result);
    }

    int height(const unique_ptr<Node>& node) const {
        if (!node) return 0;
        return 1 + max(height(node->left), height(node->right));
    }

public:
    void insert(int data) { insert(root, data); }
    void remove(int data) { remove(root, data); }

    bool search(int data) const {
        Node* current = root.get();
        while (current) {
            if (data == current->data) return true;
            current = (data < current->data) ? current->left.get() : current->right.get();
        }
        return false;
    }

    vector<int> getInorder() const {
        vector<int> result;
        inorder(root, result);
        return result;
    }

    vector<int> getPreorder() const {
        vector<int> result;
        preorder(root, result);
        return result;
    }

    vector<vector<int>> getLevelOrder() const {
        vector<vector<int>> levels;
        if (!root) return levels;

        queue<Node*> q;
        q.push(root.get());

        while (!q.empty()) {
            int size = q.size();
            vector<int> level;
            for (int i = 0; i < size; i++) {
                Node* current = q.front(); q.pop();
                level.push_back(current->data);
                if (current->left) q.push(current->left.get());
                if (current->right) q.push(current->right.get());
            }
            levels.push_back(level);
        }
        return levels;
    }

    int getHeight() const { return height(root); }
};

// Helper to print vectors
void printVec(const vector<int>& v) {
    for (int x : v) cout << x << " ";
    cout << endl;
}

int main() {
    cout << "=== Binary Search Tree in C++ ===" << endl;

    // Custom BST
    cout << "\n--- Custom BST ---" << endl;
    BST tree;
    for (int v : {50, 30, 70, 20, 40, 60, 80, 10, 35, 65}) {
        tree.insert(v);
    }

    cout << "Inorder (sorted): ";
    printVec(tree.getInorder());

    cout << "Preorder: ";
    printVec(tree.getPreorder());

    cout << "Level-order:" << endl;
    for (const auto& level : tree.getLevelOrder()) {
        cout << "  ";
        printVec(level);
    }

    cout << "Height: " << tree.getHeight() << endl;
    cout << "Search 40: " << (tree.search(40) ? "Found" : "Not found") << endl;
    cout << "Search 99: " << (tree.search(99) ? "Found" : "Not found") << endl;

    tree.remove(20);
    cout << "\nAfter delete 20: ";
    printVec(tree.getInorder());

    tree.remove(50);
    cout << "After delete 50: ";
    printVec(tree.getInorder());

    // ---- STL std::set (Red-Black Tree) ----
    cout << "\n--- std::set (Balanced BST - Red-Black Tree) ---" << endl;
    set<int> s = {50, 30, 70, 20, 40, 60, 80};

    // Insert
    s.insert(35);
    s.insert(65);

    // Always sorted!
    cout << "Elements (sorted): ";
    for (int v : s) cout << v << " ";
    cout << endl;

    // Search - O(log n)
    cout << "Count of 40: " << s.count(40) << endl;
    cout << "Count of 99: " << s.count(99) << endl;

    // Lower/upper bound
    auto it = s.lower_bound(35);
    cout << "Lower bound of 35: " << *it << endl;
    it = s.upper_bound(60);
    cout << "Upper bound of 60: " << *it << endl;

    // Erase
    s.erase(30);
    cout << "After erase 30: ";
    for (int v : s) cout << v << " ";
    cout << endl;

    // ---- std::map (Key-Value BST) ----
    cout << "\n--- std::map (Key-Value Balanced BST) ---" << endl;
    map<string, int> grades;
    grades["Alice"] = 95;
    grades["Bob"] = 87;
    grades["Charlie"] = 92;
    grades["Diana"] = 88;

    // Automatically sorted by key
    for (const auto& [name, grade] : grades) {
        cout << "  " << name << ": " << grade << endl;
    }

    // Find
    if (auto it = grades.find("Bob"); it != grades.end()) {
        cout << "Bob's grade: " << it->second << endl;
    }

    return 0;
}
