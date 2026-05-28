/*
 * Queue in C++
 * Demonstrates: std::queue, std::deque, std::priority_queue, applications
 */
#include <iostream>
#include <queue>
#include <deque>
#include <vector>
#include <string>
#include <functional>  // greater<>
using namespace std;

// Application: BFS using std::queue
void bfs(const vector<vector<int>>& graph, int start) {
    vector<bool> visited(graph.size(), false);
    queue<int> q;

    visited[start] = true;
    q.push(start);
    cout << "BFS from node " << start << ": ";

    while (!q.empty()) {
        int current = q.front();
        q.pop();
        cout << current << " ";

        for (int neighbor : graph[current]) {
            if (!visited[neighbor]) {
                visited[neighbor] = true;
                q.push(neighbor);
            }
        }
    }
    cout << endl;
}

// Application: Task scheduler simulation
struct Task {
    string name;
    int priority;
    // For priority_queue: lower number = higher priority
    bool operator>(const Task& other) const {
        return priority > other.priority;
    }
};

int main() {
    cout << "=== Queue in C++ ===" << endl;

    // std::queue — FIFO
    cout << "\n--- std::queue (FIFO) ---" << endl;
    queue<int> q;
    for (int i = 1; i <= 5; i++) q.push(i * 10);

    cout << "Front: " << q.front() << ", Back: " << q.back()
         << ", Size: " << q.size() << endl;

    cout << "Dequeue: ";
    while (!q.empty()) {
        cout << q.front() << " ";
        q.pop();
    }
    cout << endl;

    // std::deque — double-ended queue
    cout << "\n--- std::deque (Double-ended) ---" << endl;
    deque<string> dq;
    dq.push_back("B");
    dq.push_back("C");
    dq.push_front("A");
    dq.push_back("D");

    cout << "Contents: ";
    for (const auto& s : dq) cout << s << " ";
    cout << endl;

    dq.pop_front();  // Remove A
    dq.pop_back();   // Remove D
    cout << "After pop front & back: ";
    for (const auto& s : dq) cout << s << " ";
    cout << endl;

    // Random access (like vector)
    cout << "dq[0] = " << dq[0] << ", dq[1] = " << dq[1] << endl;

    // std::priority_queue — max-heap by default
    cout << "\n--- std::priority_queue ---" << endl;
    priority_queue<int> maxHeap;
    maxHeap.push(30);
    maxHeap.push(10);
    maxHeap.push(50);
    maxHeap.push(20);
    maxHeap.push(40);

    cout << "Max-heap (pop order): ";
    while (!maxHeap.empty()) {
        cout << maxHeap.top() << " ";
        maxHeap.pop();
    }
    cout << endl;

    // Min-heap using greater<>
    priority_queue<int, vector<int>, greater<int>> minHeap;
    minHeap.push(30);
    minHeap.push(10);
    minHeap.push(50);
    minHeap.push(20);

    cout << "Min-heap (pop order): ";
    while (!minHeap.empty()) {
        cout << minHeap.top() << " ";
        minHeap.pop();
    }
    cout << endl;

    // Priority queue with custom struct
    cout << "\n--- Task Scheduler (Priority Queue) ---" << endl;
    priority_queue<Task, vector<Task>, greater<Task>> scheduler;
    scheduler.push({"Send email", 3});
    scheduler.push({"Fix critical bug", 1});
    scheduler.push({"Write tests", 2});
    scheduler.push({"Update docs", 4});

    cout << "Processing tasks by priority:" << endl;
    while (!scheduler.empty()) {
        auto task = scheduler.top();
        scheduler.pop();
        cout << "  [Priority " << task.priority << "] " << task.name << endl;
    }

    // BFS Application
    cout << "\n--- BFS using std::queue ---" << endl;
    vector<vector<int>> graph = {
        {1, 2},     // 0 -> 1, 2
        {0, 3, 4},  // 1 -> 0, 3, 4
        {0, 4},     // 2 -> 0, 4
        {1},        // 3 -> 1
        {1, 2}      // 4 -> 1, 2
    };
    bfs(graph, 0);

    // Level-order traversal concept
    cout << "\n--- Level-order (BFS) pattern ---" << endl;
    queue<int> levelQ;
    levelQ.push(1);
    int level = 0;
    while (!levelQ.empty()) {
        int levelSize = levelQ.size();
        cout << "Level " << level << ": ";
        for (int i = 0; i < levelSize; i++) {
            int node = levelQ.front(); levelQ.pop();
            cout << node << " ";
            // Simulate adding children
            if (node * 2 <= 7) levelQ.push(node * 2);
            if (node * 2 + 1 <= 7) levelQ.push(node * 2 + 1);
        }
        cout << endl;
        level++;
    }

    return 0;
}
