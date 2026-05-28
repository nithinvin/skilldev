/*
 * Linked List in C
 * Demonstrates: singly linked list with all operations
 */
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
    int data;
    struct Node *next;
} Node;

typedef struct {
    Node *head;
    int size;
} LinkedList;

LinkedList* list_create(void) {
    LinkedList *list = (LinkedList *)malloc(sizeof(LinkedList));
    list->head = NULL;
    list->size = 0;
    return list;
}

/* Insert at front - O(1) */
void list_push_front(LinkedList *list, int data) {
    Node *new_node = (Node *)malloc(sizeof(Node));
    new_node->data = data;
    new_node->next = list->head;
    list->head = new_node;
    list->size++;
}

/* Insert at back - O(n) */
void list_push_back(LinkedList *list, int data) {
    Node *new_node = (Node *)malloc(sizeof(Node));
    new_node->data = data;
    new_node->next = NULL;

    if (list->head == NULL) {
        list->head = new_node;
    } else {
        Node *current = list->head;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = new_node;
    }
    list->size++;
}

/* Delete by value - O(n) */
int list_delete(LinkedList *list, int data) {
    if (list->head == NULL) return 0;

    if (list->head->data == data) {
        Node *temp = list->head;
        list->head = list->head->next;
        free(temp);
        list->size--;
        return 1;
    }

    Node *current = list->head;
    while (current->next != NULL && current->next->data != data) {
        current = current->next;
    }

    if (current->next == NULL) return 0;

    Node *temp = current->next;
    current->next = temp->next;
    free(temp);
    list->size--;
    return 1;
}

/* Search - O(n) */
Node* list_find(LinkedList *list, int data) {
    Node *current = list->head;
    while (current != NULL) {
        if (current->data == data) return current;
        current = current->next;
    }
    return NULL;
}

/* Reverse - O(n) */
void list_reverse(LinkedList *list) {
    Node *prev = NULL;
    Node *current = list->head;
    Node *next = NULL;

    while (current != NULL) {
        next = current->next;
        current->next = prev;
        prev = current;
        current = next;
    }
    list->head = prev;
}

/* Print */
void list_print(const LinkedList *list) {
    Node *current = list->head;
    printf("[");
    while (current != NULL) {
        printf("%d", current->data);
        if (current->next) printf(" -> ");
        current = current->next;
    }
    printf("] (size=%d)\n", list->size);
}

/* Destroy - free all memory */
void list_destroy(LinkedList *list) {
    Node *current = list->head;
    while (current != NULL) {
        Node *next = current->next;
        free(current);
        current = next;
    }
    free(list);
}

int main(void) {
    printf("=== Linked List in C ===\n\n");

    LinkedList *list = list_create();

    /* Insert operations */
    list_push_back(list, 10);
    list_push_back(list, 20);
    list_push_back(list, 30);
    list_push_front(list, 5);
    list_push_front(list, 1);

    printf("After insertions: ");
    list_print(list);

    /* Search */
    Node *found = list_find(list, 20);
    printf("Search 20: %s\n", found ? "Found" : "Not found");
    found = list_find(list, 99);
    printf("Search 99: %s\n", found ? "Found" : "Not found");

    /* Delete */
    list_delete(list, 20);
    printf("After deleting 20: ");
    list_print(list);

    list_delete(list, 1);
    printf("After deleting 1: ");
    list_print(list);

    /* Reverse */
    list_reverse(list);
    printf("After reverse: ");
    list_print(list);

    /* Cleanup */
    list_destroy(list);
    printf("\nList destroyed. No memory leaks (if we did it right!)\n");

    return 0;
}
