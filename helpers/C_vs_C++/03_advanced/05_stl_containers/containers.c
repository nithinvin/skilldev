/*
 * STL-equivalent operations in C
 * Demonstrates: manual implementations of what STL provides in C++
 * (dynamic array, map-like structure, set-like structure)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ===== Dynamic Array (like std::vector) ===== */
typedef struct {
    int *data;
    int size;
    int capacity;
} Vector;

Vector vec_create(int initial_cap) {
    Vector v;
    v.data = (int *)malloc(initial_cap * sizeof(int));
    v.size = 0;
    v.capacity = initial_cap;
    return v;
}

void vec_push_back(Vector *v, int value) {
    if (v->size == v->capacity) {
        v->capacity *= 2;
        v->data = (int *)realloc(v->data, v->capacity * sizeof(int));
    }
    v->data[v->size++] = value;
}

void vec_erase(Vector *v, int index) {
    memmove(v->data + index, v->data + index + 1, (v->size - index - 1) * sizeof(int));
    v->size--;
}

void vec_destroy(Vector *v) { free(v->data); }

/* ===== Sorted Set (like std::set, using sorted array + binary search) ===== */
typedef struct {
    int *data;
    int size;
    int capacity;
} SortedSet;

SortedSet set_create(int cap) {
    SortedSet s;
    s.data = (int *)malloc(cap * sizeof(int));
    s.size = 0;
    s.capacity = cap;
    return s;
}

int set_binary_search(SortedSet *s, int value) {
    int lo = 0, hi = s->size - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (s->data[mid] == value) return mid;
        else if (s->data[mid] < value) lo = mid + 1;
        else hi = mid - 1;
    }
    return -(lo + 1);  /* Insertion point (negative) */
}

int set_insert(SortedSet *s, int value) {
    int pos = set_binary_search(s, value);
    if (pos >= 0) return 0;  /* Already exists */
    pos = -(pos + 1);

    if (s->size == s->capacity) {
        s->capacity *= 2;
        s->data = (int *)realloc(s->data, s->capacity * sizeof(int));
    }
    memmove(s->data + pos + 1, s->data + pos, (s->size - pos) * sizeof(int));
    s->data[pos] = value;
    s->size++;
    return 1;
}

int set_contains(SortedSet *s, int value) {
    return set_binary_search(s, value) >= 0;
}

void set_destroy(SortedSet *s) { free(s->data); }

/* ===== Key-Value Map (like std::map, using sorted array of pairs) ===== */
typedef struct {
    char key[50];
    int value;
} KVPair;

typedef struct {
    KVPair *data;
    int size;
    int capacity;
} Map;

Map map_create(int cap) {
    Map m;
    m.data = (KVPair *)malloc(cap * sizeof(KVPair));
    m.size = 0;
    m.capacity = cap;
    return m;
}

int map_find(Map *m, const char *key) {
    for (int i = 0; i < m->size; i++) {
        if (strcmp(m->data[i].key, key) == 0) return i;
    }
    return -1;
}

void map_put(Map *m, const char *key, int value) {
    int idx = map_find(m, key);
    if (idx >= 0) {
        m->data[idx].value = value;
        return;
    }
    if (m->size == m->capacity) {
        m->capacity *= 2;
        m->data = (KVPair *)realloc(m->data, m->capacity * sizeof(KVPair));
    }
    strncpy(m->data[m->size].key, key, 49);
    m->data[m->size].key[49] = '\0';
    m->data[m->size].value = value;
    m->size++;
}

int map_get(Map *m, const char *key, int *value) {
    int idx = map_find(m, key);
    if (idx < 0) return 0;
    *value = m->data[idx].value;
    return 1;
}

void map_destroy(Map *m) { free(m->data); }

int main(void) {
    printf("=== STL-Equivalent Operations in C ===\n\n");

    /* Vector operations */
    printf("--- Dynamic Array (Vector) ---\n");
    Vector v = vec_create(4);
    for (int i = 0; i < 10; i++) vec_push_back(&v, i * 10);

    printf("Elements: ");
    for (int i = 0; i < v.size; i++) printf("%d ", v.data[i]);
    printf("\nSize: %d, Capacity: %d\n", v.size, v.capacity);

    vec_erase(&v, 3);  /* Remove index 3 */
    printf("After erase[3]: ");
    for (int i = 0; i < v.size; i++) printf("%d ", v.data[i]);
    printf("\n");
    vec_destroy(&v);

    /* Set operations */
    printf("\n--- Sorted Set ---\n");
    SortedSet s = set_create(8);
    int values[] = {5, 3, 8, 1, 9, 3, 5, 7};  /* Duplicates will be ignored */
    for (int i = 0; i < 8; i++) set_insert(&s, values[i]);

    printf("Set: ");
    for (int i = 0; i < s.size; i++) printf("%d ", s.data[i]);
    printf("(size=%d)\n", s.size);

    printf("Contains 5? %s\n", set_contains(&s, 5) ? "Yes" : "No");
    printf("Contains 6? %s\n", set_contains(&s, 6) ? "Yes" : "No");
    set_destroy(&s);

    /* Map operations */
    printf("\n--- Key-Value Map ---\n");
    Map m = map_create(8);
    map_put(&m, "Alice", 95);
    map_put(&m, "Bob", 87);
    map_put(&m, "Charlie", 92);

    int val;
    if (map_get(&m, "Bob", &val))
        printf("Bob's score: %d\n", val);

    map_put(&m, "Bob", 90);  /* Update */
    map_get(&m, "Bob", &val);
    printf("Bob's updated score: %d\n", val);

    printf("All entries:\n");
    for (int i = 0; i < m.size; i++)
        printf("  %s: %d\n", m.data[i].key, m.data[i].value);

    map_destroy(&m);

    printf("\n--- Lines of Code Comparison ---\n");
    printf("Dynamic Array: ~30 lines in C, 0 lines in C++ (std::vector)\n");
    printf("Sorted Set:    ~40 lines in C, 0 lines in C++ (std::set)\n");
    printf("Key-Value Map: ~40 lines in C, 0 lines in C++ (std::map)\n");

    return 0;
}
