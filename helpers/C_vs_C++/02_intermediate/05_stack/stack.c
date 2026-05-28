/*
 * Stack in C
 * Demonstrates: array-based and linked-list-based stack implementations
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STACK_SIZE 100

/* ===== Array-based Stack ===== */
typedef struct {
    int data[MAX_STACK_SIZE];
    int top;
} ArrayStack;

void astack_init(ArrayStack *s) { s->top = -1; }
int astack_is_empty(ArrayStack *s) { return s->top == -1; }
int astack_is_full(ArrayStack *s) { return s->top == MAX_STACK_SIZE - 1; }

int astack_push(ArrayStack *s, int value) {
    if (astack_is_full(s)) return -1;
    s->data[++s->top] = value;
    return 0;
}

int astack_pop(ArrayStack *s, int *value) {
    if (astack_is_empty(s)) return -1;
    *value = s->data[s->top--];
    return 0;
}

int astack_peek(ArrayStack *s, int *value) {
    if (astack_is_empty(s)) return -1;
    *value = s->data[s->top];
    return 0;
}

/* ===== Linked-list-based Stack ===== */
typedef struct StackNode {
    int data;
    struct StackNode *next;
} StackNode;

typedef struct {
    StackNode *top;
    int size;
} LLStack;

LLStack* llstack_create(void) {
    LLStack *s = (LLStack *)malloc(sizeof(LLStack));
    s->top = NULL;
    s->size = 0;
    return s;
}

void llstack_push(LLStack *s, int value) {
    StackNode *node = (StackNode *)malloc(sizeof(StackNode));
    node->data = value;
    node->next = s->top;
    s->top = node;
    s->size++;
}

int llstack_pop(LLStack *s, int *value) {
    if (s->top == NULL) return -1;
    StackNode *temp = s->top;
    *value = temp->data;
    s->top = temp->next;
    free(temp);
    s->size--;
    return 0;
}

void llstack_destroy(LLStack *s) {
    StackNode *current = s->top;
    while (current) {
        StackNode *next = current->next;
        free(current);
        current = next;
    }
    free(s);
}

/* ===== Application: Balanced Parentheses ===== */
int check_balanced(const char *expr) {
    ArrayStack s;
    astack_init(&s);

    for (int i = 0; expr[i] != '\0'; i++) {
        char ch = expr[i];
        if (ch == '(' || ch == '[' || ch == '{') {
            astack_push(&s, ch);
        } else if (ch == ')' || ch == ']' || ch == '}') {
            int top;
            if (astack_pop(&s, &top) == -1) return 0;
            if ((ch == ')' && top != '(') ||
                (ch == ']' && top != '[') ||
                (ch == '}' && top != '{'))
                return 0;
        }
    }
    return astack_is_empty(&s);
}

int main(void) {
    printf("=== Stack in C ===\n\n");

    /* Array-based stack */
    printf("--- Array-based Stack ---\n");
    ArrayStack as;
    astack_init(&as);

    astack_push(&as, 10);
    astack_push(&as, 20);
    astack_push(&as, 30);

    int val;
    astack_peek(&as, &val);
    printf("Top: %d\n", val);

    printf("Popping: ");
    while (!astack_is_empty(&as)) {
        astack_pop(&as, &val);
        printf("%d ", val);
    }
    printf("\n");

    /* Linked-list stack */
    printf("\n--- Linked-list Stack ---\n");
    LLStack *ls = llstack_create();
    llstack_push(ls, 100);
    llstack_push(ls, 200);
    llstack_push(ls, 300);

    printf("Popping: ");
    while (ls->size > 0) {
        llstack_pop(ls, &val);
        printf("%d ", val);
    }
    printf("\n");
    llstack_destroy(ls);

    /* Application: Balanced parentheses */
    printf("\n--- Balanced Parentheses ---\n");
    const char *exprs[] = {
        "{[()]}",
        "((()))",
        "{[(])}",
        "(()",
        "int main() { if (x[0] > 0) { return 1; } }"
    };

    for (int i = 0; i < 5; i++) {
        printf("  \"%s\" -> %s\n", exprs[i],
               check_balanced(exprs[i]) ? "Balanced" : "NOT Balanced");
    }

    return 0;
}
