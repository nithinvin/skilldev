/*
 * Queue in C
 * Demonstrates: circular array queue, linked-list queue, priority queue
 */
#include <stdio.h>
#include <stdlib.h>

#define MAX_QUEUE_SIZE 10

/* ===== Circular Array Queue ===== */
typedef struct {
    int data[MAX_QUEUE_SIZE];
    int front, rear, size;
} CircularQueue;

void cq_init(CircularQueue *q) {
    q->front = 0;
    q->rear = -1;
    q->size = 0;
}

int cq_is_empty(CircularQueue *q) { return q->size == 0; }
int cq_is_full(CircularQueue *q) { return q->size == MAX_QUEUE_SIZE; }

int cq_enqueue(CircularQueue *q, int value) {
    if (cq_is_full(q)) return -1;
    q->rear = (q->rear + 1) % MAX_QUEUE_SIZE;
    q->data[q->rear] = value;
    q->size++;
    return 0;
}

int cq_dequeue(CircularQueue *q, int *value) {
    if (cq_is_empty(q)) return -1;
    *value = q->data[q->front];
    q->front = (q->front + 1) % MAX_QUEUE_SIZE;
    q->size--;
    return 0;
}

int cq_peek(CircularQueue *q, int *value) {
    if (cq_is_empty(q)) return -1;
    *value = q->data[q->front];
    return 0;
}

/* ===== Linked-list Queue ===== */
typedef struct QNode {
    int data;
    struct QNode *next;
} QNode;

typedef struct {
    QNode *front;
    QNode *rear;
    int size;
} LLQueue;

LLQueue* llq_create(void) {
    LLQueue *q = (LLQueue *)malloc(sizeof(LLQueue));
    q->front = q->rear = NULL;
    q->size = 0;
    return q;
}

void llq_enqueue(LLQueue *q, int value) {
    QNode *node = (QNode *)malloc(sizeof(QNode));
    node->data = value;
    node->next = NULL;
    if (q->rear == NULL) {
        q->front = q->rear = node;
    } else {
        q->rear->next = node;
        q->rear = node;
    }
    q->size++;
}

int llq_dequeue(LLQueue *q, int *value) {
    if (q->front == NULL) return -1;
    QNode *temp = q->front;
    *value = temp->data;
    q->front = temp->next;
    if (q->front == NULL) q->rear = NULL;
    free(temp);
    q->size--;
    return 0;
}

void llq_destroy(LLQueue *q) {
    QNode *current = q->front;
    while (current) {
        QNode *next = current->next;
        free(current);
        current = next;
    }
    free(q);
}

/* ===== Application: BFS using Queue ===== */
#define MAX_NODES 10
void bfs(int graph[MAX_NODES][MAX_NODES], int nodes, int start) {
    int visited[MAX_NODES] = {0};
    CircularQueue q;
    cq_init(&q);

    visited[start] = 1;
    cq_enqueue(&q, start);
    printf("BFS from node %d: ", start);

    while (!cq_is_empty(&q)) {
        int current;
        cq_dequeue(&q, &current);
        printf("%d ", current);

        for (int i = 0; i < nodes; i++) {
            if (graph[current][i] && !visited[i]) {
                visited[i] = 1;
                cq_enqueue(&q, i);
            }
        }
    }
    printf("\n");
}

int main(void) {
    printf("=== Queue in C ===\n\n");

    /* Circular Queue */
    printf("--- Circular Array Queue ---\n");
    CircularQueue cq;
    cq_init(&cq);

    for (int i = 1; i <= 5; i++) cq_enqueue(&cq, i * 10);

    int val;
    cq_peek(&cq, &val);
    printf("Front: %d, Size: %d\n", val, cq.size);

    printf("Dequeue: ");
    while (!cq_is_empty(&cq)) {
        cq_dequeue(&cq, &val);
        printf("%d ", val);
    }
    printf("\n");

    /* Linked-list Queue */
    printf("\n--- Linked-list Queue ---\n");
    LLQueue *llq = llq_create();
    for (int i = 1; i <= 5; i++) llq_enqueue(llq, i * 100);

    printf("Dequeue: ");
    while (llq->size > 0) {
        llq_dequeue(llq, &val);
        printf("%d ", val);
    }
    printf("\n");
    llq_destroy(llq);

    /* BFS Application */
    printf("\n--- BFS using Queue ---\n");
    int graph[MAX_NODES][MAX_NODES] = {
        {0,1,1,0,0},
        {1,0,0,1,1},
        {1,0,0,0,1},
        {0,1,0,0,0},
        {0,1,1,0,0}
    };
    bfs(graph, 5, 0);

    return 0;
}
