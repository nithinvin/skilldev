/*
 * Graph (BFS & DFS) in C++
 * Demonstrates: adjacency list with STL, BFS, DFS, Dijkstra, topological sort
 */
#include <iostream>
#include <vector>
#include <queue>
#include <stack>
#include <unordered_map>
#include <unordered_set>
#include <algorithm>
#include <climits>
using namespace std;

class Graph {
private:
    int vertices;
    bool directed;
    vector<vector<pair<int, int>>> adj;  // adj[u] = {(v, weight), ...}

public:
    Graph(int v, bool dir = false) : vertices(v), directed(dir), adj(v) {}

    void addEdge(int src, int dest, int weight = 1) {
        adj[src].push_back({dest, weight});
        if (!directed) adj[dest].push_back({src, weight});
    }

    // BFS
    vector<int> bfs(int start) const {
        vector<int> order;
        vector<bool> visited(vertices, false);
        queue<int> q;

        visited[start] = true;
        q.push(start);

        while (!q.empty()) {
            int current = q.front(); q.pop();
            order.push_back(current);

            for (auto [neighbor, weight] : adj[current]) {
                if (!visited[neighbor]) {
                    visited[neighbor] = true;
                    q.push(neighbor);
                }
            }
        }
        return order;
    }

    // DFS (iterative)
    vector<int> dfs(int start) const {
        vector<int> order;
        vector<bool> visited(vertices, false);
        stack<int> s;

        s.push(start);
        while (!s.empty()) {
            int current = s.top(); s.pop();
            if (visited[current]) continue;
            visited[current] = true;
            order.push_back(current);

            for (auto [neighbor, weight] : adj[current]) {
                if (!visited[neighbor]) s.push(neighbor);
            }
        }
        return order;
    }

    // Shortest path (BFS for unweighted)
    vector<int> shortestPath(int start) const {
        vector<int> dist(vertices, -1);
        queue<int> q;

        dist[start] = 0;
        q.push(start);

        while (!q.empty()) {
            int current = q.front(); q.pop();
            for (auto [neighbor, weight] : adj[current]) {
                if (dist[neighbor] == -1) {
                    dist[neighbor] = dist[current] + 1;
                    q.push(neighbor);
                }
            }
        }
        return dist;
    }

    // Dijkstra's algorithm (weighted shortest path)
    vector<int> dijkstra(int start) const {
        vector<int> dist(vertices, INT_MAX);
        // Min-heap: {distance, vertex}
        priority_queue<pair<int,int>, vector<pair<int,int>>, greater<>> pq;

        dist[start] = 0;
        pq.push({0, start});

        while (!pq.empty()) {
            auto [d, u] = pq.top(); pq.pop();
            if (d > dist[u]) continue;  // Skip outdated entries

            for (auto [v, weight] : adj[u]) {
                if (dist[u] + weight < dist[v]) {
                    dist[v] = dist[u] + weight;
                    pq.push({dist[v], v});
                }
            }
        }
        return dist;
    }

    // Topological Sort (Kahn's algorithm — BFS-based)
    vector<int> topologicalSort() const {
        vector<int> inDegree(vertices, 0);
        for (int u = 0; u < vertices; u++) {
            for (auto [v, w] : adj[u]) {
                inDegree[v]++;
            }
        }

        queue<int> q;
        for (int i = 0; i < vertices; i++) {
            if (inDegree[i] == 0) q.push(i);
        }

        vector<int> order;
        while (!q.empty()) {
            int u = q.front(); q.pop();
            order.push_back(u);
            for (auto [v, w] : adj[u]) {
                if (--inDegree[v] == 0) q.push(v);
            }
        }
        return order;  // If size != vertices, cycle exists
    }

    // Connected components (undirected)
    int countComponents() const {
        vector<bool> visited(vertices, false);
        int count = 0;

        for (int i = 0; i < vertices; i++) {
            if (!visited[i]) {
                count++;
                queue<int> q;
                q.push(i);
                visited[i] = true;
                while (!q.empty()) {
                    int u = q.front(); q.pop();
                    for (auto [v, w] : adj[u]) {
                        if (!visited[v]) {
                            visited[v] = true;
                            q.push(v);
                        }
                    }
                }
            }
        }
        return count;
    }
};

void printVec(const string& label, const vector<int>& v) {
    cout << label;
    for (int x : v) cout << x << " ";
    cout << endl;
}

int main() {
    cout << "=== Graph Algorithms in C++ ===" << endl;

    // Undirected graph
    cout << "\n--- Undirected Graph ---" << endl;
    Graph g(6);
    g.addEdge(0, 1);
    g.addEdge(0, 2);
    g.addEdge(1, 3);
    g.addEdge(1, 4);
    g.addEdge(2, 4);
    g.addEdge(3, 5);
    g.addEdge(4, 5);

    printVec("BFS from 0: ", g.bfs(0));
    printVec("DFS from 0: ", g.dfs(0));

    auto dist = g.shortestPath(0);
    cout << "Shortest distances from 0:" << endl;
    for (int i = 0; i < 6; i++)
        cout << "  0 -> " << i << ": " << dist[i] << endl;

    cout << "Connected components: " << g.countComponents() << endl;

    // Directed graph — topological sort
    cout << "\n--- Directed Graph (Topological Sort) ---" << endl;
    Graph dag(6, true);
    dag.addEdge(5, 2);
    dag.addEdge(5, 0);
    dag.addEdge(4, 0);
    dag.addEdge(4, 1);
    dag.addEdge(2, 3);
    dag.addEdge(3, 1);

    printVec("Topological order: ", dag.topologicalSort());

    // Weighted graph — Dijkstra
    cout << "\n--- Weighted Graph (Dijkstra) ---" << endl;
    Graph wg(5, true);
    wg.addEdge(0, 1, 4);
    wg.addEdge(0, 2, 1);
    wg.addEdge(2, 1, 2);
    wg.addEdge(1, 3, 1);
    wg.addEdge(2, 3, 5);
    wg.addEdge(3, 4, 3);

    auto dijkDist = wg.dijkstra(0);
    cout << "Dijkstra from 0:" << endl;
    for (int i = 0; i < 5; i++)
        cout << "  0 -> " << i << ": " << (dijkDist[i] == INT_MAX ? -1 : dijkDist[i]) << endl;

    return 0;
}
