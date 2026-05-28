/*
 * Graph (BFS & DFS) in C
 * Demonstrates: adjacency list, BFS, DFS, topological sort, shortest path
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VERTICES 20

/* Adjacency list representation */
typedef struct AdjNode {
    int vertex;
    int weight;
    struct AdjNode *next;
} AdjNode;

typedef struct {
    AdjNode *adj[MAX_VERTICES];
    int num_vertices;
    int directed;
} Graph;

Graph* graph_create(int vertices, int directed) {
    Graph *g = (Graph *)malloc(sizeof(Graph));
    g->num_vertices = vertices;
    g->directed = directed;
    for (int i = 0; i < vertices; i++) {
        g->adj[i] = NULL;
    }
    return g;
}

void graph_add_edge(Graph *g, int src, int dest, int weight) {
    AdjNode *node = (AdjNode *)malloc(sizeof(AdjNode));
    node->vertex = dest;
    node->weight = weight;
    node->next = g->adj[src];
    g->adj[src] = node;

    if (!g->directed) {
        node = (AdjNode *)malloc(sizeof(AdjNode));
        node->vertex = src;
        node->weight = weight;
        node->next = g->adj[dest];
        g->adj[dest] = node;
    }
}

/* BFS */
void bfs(Graph *g, int start) {
    int visited[MAX_VERTICES] = {0};
    int queue[MAX_VERTICES];
    int front = 0, rear = 0;

    visited[start] = 1;
    queue[rear++] = start;

    printf("BFS from %d: ", start);
    while (front < rear) {
        int current = queue[front++];
        printf("%d ", current);

        AdjNode *adj = g->adj[current];
        while (adj) {
            if (!visited[adj->vertex]) {
                visited[adj->vertex] = 1;
                queue[rear++] = adj->vertex;
            }
            adj = adj->next;
        }
    }
    printf("\n");
}

/* DFS (iterative using stack) */
void dfs_iterative(Graph *g, int start) {
    int visited[MAX_VERTICES] = {0};
    int stack[MAX_VERTICES];
    int top = -1;

    stack[++top] = start;

    printf("DFS from %d: ", start);
    while (top >= 0) {
        int current = stack[top--];
        if (visited[current]) continue;
        visited[current] = 1;
        printf("%d ", current);

        AdjNode *adj = g->adj[current];
        while (adj) {
            if (!visited[adj->vertex]) {
                stack[++top] = adj->vertex;
            }
            adj = adj->next;
        }
    }
    printf("\n");
}

/* DFS recursive */
void dfs_recursive_helper(Graph *g, int vertex, int visited[]) {
    visited[vertex] = 1;
    printf("%d ", vertex);

    AdjNode *adj = g->adj[vertex];
    while (adj) {
        if (!visited[adj->vertex]) {
            dfs_recursive_helper(g, adj->vertex, visited);
        }
        adj = adj->next;
    }
}

void dfs_recursive(Graph *g, int start) {
    int visited[MAX_VERTICES] = {0};
    printf("DFS (recursive) from %d: ", start);
    dfs_recursive_helper(g, start, visited);
    printf("\n");
}

/* Topological Sort (DFS-based) */
void topo_helper(Graph *g, int v, int visited[], int stack[], int *top) {
    visited[v] = 1;
    AdjNode *adj = g->adj[v];
    while (adj) {
        if (!visited[adj->vertex])
            topo_helper(g, adj->vertex, visited, stack, top);
        adj = adj->next;
    }
    stack[++(*top)] = v;
}

void topological_sort(Graph *g) {
    int visited[MAX_VERTICES] = {0};
    int stack[MAX_VERTICES];
    int top = -1;

    for (int i = 0; i < g->num_vertices; i++) {
        if (!visited[i])
            topo_helper(g, i, visited, stack, &top);
    }

    printf("Topological order: ");
    while (top >= 0) printf("%d ", stack[top--]);
    printf("\n");
}

/* Shortest path (BFS for unweighted) */
void shortest_path_bfs(Graph *g, int start) {
    int dist[MAX_VERTICES];
    memset(dist, -1, sizeof(dist));
    int queue[MAX_VERTICES];
    int front = 0, rear = 0;

    dist[start] = 0;
    queue[rear++] = start;

    while (front < rear) {
        int current = queue[front++];
        AdjNode *adj = g->adj[current];
        while (adj) {
            if (dist[adj->vertex] == -1) {
                dist[adj->vertex] = dist[current] + 1;
                queue[rear++] = adj->vertex;
            }
            adj = adj->next;
        }
    }

    printf("Shortest distances from %d:\n", start);
    for (int i = 0; i < g->num_vertices; i++) {
        printf("  %d -> %d: %d\n", start, i, dist[i]);
    }
}

void graph_destroy(Graph *g) {
    for (int i = 0; i < g->num_vertices; i++) {
        AdjNode *current = g->adj[i];
        while (current) {
            AdjNode *next = current->next;
            free(current);
            current = next;
        }
    }
    free(g);
}

int main(void) {
    printf("=== Graph Algorithms in C ===\n\n");

    /* Undirected graph */
    printf("--- Undirected Graph ---\n");
    Graph *g = graph_create(6, 0);
    graph_add_edge(g, 0, 1, 1);
    graph_add_edge(g, 0, 2, 1);
    graph_add_edge(g, 1, 3, 1);
    graph_add_edge(g, 1, 4, 1);
    graph_add_edge(g, 2, 4, 1);
    graph_add_edge(g, 3, 5, 1);
    graph_add_edge(g, 4, 5, 1);

    bfs(g, 0);
    dfs_iterative(g, 0);
    dfs_recursive(g, 0);
    printf("\n");
    shortest_path_bfs(g, 0);
    graph_destroy(g);

    /* Directed graph for topological sort */
    printf("\n--- Directed Graph (Topological Sort) ---\n");
    Graph *dag = graph_create(6, 1);
    graph_add_edge(dag, 5, 2, 1);
    graph_add_edge(dag, 5, 0, 1);
    graph_add_edge(dag, 4, 0, 1);
    graph_add_edge(dag, 4, 1, 1);
    graph_add_edge(dag, 2, 3, 1);
    graph_add_edge(dag, 3, 1, 1);

    topological_sort(dag);
    graph_destroy(dag);

    return 0;
}
