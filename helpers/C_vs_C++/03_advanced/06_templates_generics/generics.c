/*
 * Generics in C
 * Demonstrates: void* generics, macros for type-generic code, _Generic (C11)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ===== Approach 1: void* (runtime generics) ===== */
typedef int (*CompareFunc)(const void *, const void *);

/* Generic swap using void* */
void generic_swap(void *a, void *b, size_t size) {
    void *temp = malloc(size);
    memcpy(temp, a, size);
    memcpy(a, b, size);
    memcpy(b, temp, size);
    free(temp);
}

/* Generic find */
void* generic_find(void *array, int count, size_t elem_size,
                   const void *target, CompareFunc cmp) {
    for (int i = 0; i < count; i++) {
        void *current = (char *)array + i * elem_size;
        if (cmp(current, target) == 0) return current;
    }
    return NULL;
}

/* Comparators */
int int_compare(const void *a, const void *b) {
    return *(int *)a - *(int *)b;
}

int str_compare(const void *a, const void *b) {
    return strcmp(*(char **)a, *(char **)b);
}

/* ===== Approach 2: Macros (compile-time generics) ===== */
#define DEFINE_VECTOR(type, name)                                    \
    typedef struct {                                                 \
        type *data;                                                  \
        int size;                                                    \
        int capacity;                                                \
    } name##_Vector;                                                 \
                                                                     \
    name##_Vector name##_vec_create(int cap) {                       \
        name##_Vector v;                                             \
        v.data = (type *)malloc(cap * sizeof(type));                 \
        v.size = 0;                                                  \
        v.capacity = cap;                                            \
        return v;                                                    \
    }                                                                \
                                                                     \
    void name##_vec_push(name##_Vector *v, type value) {             \
        if (v->size == v->capacity) {                                \
            v->capacity *= 2;                                        \
            v->data = (type *)realloc(v->data, v->capacity * sizeof(type)); \
        }                                                            \
        v->data[v->size++] = value;                                  \
    }                                                                \
                                                                     \
    void name##_vec_destroy(name##_Vector *v) { free(v->data); }

/* Generate vector types for int and double */
DEFINE_VECTOR(int, int)
DEFINE_VECTOR(double, double)

/* ===== Approach 3: _Generic (C11) ===== */
#define print_value(x) _Generic((x),    \
    int: printf("%d", x),               \
    double: printf("%f", x),            \
    float: printf("%f", x),             \
    char*: printf("%s", x),             \
    default: printf("unknown type")     \
)

#define max_val(a, b) _Generic((a),     \
    int: ((a) > (b) ? (a) : (b)),       \
    double: ((a) > (b) ? (a) : (b)),    \
    float: ((a) > (b) ? (a) : (b))      \
)

int main(void) {
    printf("=== Generics in C ===\n\n");

    /* void* generics */
    printf("--- void* Generics ---\n");
    int a = 10, b = 20;
    printf("Before swap: a=%d, b=%d\n", a, b);
    generic_swap(&a, &b, sizeof(int));
    printf("After swap:  a=%d, b=%d\n", a, b);

    double x = 3.14, y = 2.71;
    printf("Before swap: x=%.2f, y=%.2f\n", x, y);
    generic_swap(&x, &y, sizeof(double));
    printf("After swap:  x=%.2f, y=%.2f\n", x, y);

    /* Generic find */
    int arr[] = {10, 20, 30, 40, 50};
    int target = 30;
    int *found = (int *)generic_find(arr, 5, sizeof(int), &target, int_compare);
    printf("Find 30: %s (index %ld)\n", found ? "Found" : "Not found",
           found ? found - arr : -1);

    /* Macro-generated type-specific vectors */
    printf("\n--- Macro Generics ---\n");
    int_Vector iv = int_vec_create(4);
    for (int i = 0; i < 8; i++) int_vec_push(&iv, i * 10);
    printf("int_Vector: ");
    for (int i = 0; i < iv.size; i++) printf("%d ", iv.data[i]);
    printf("(size=%d, cap=%d)\n", iv.size, iv.capacity);
    int_vec_destroy(&iv);

    double_Vector dv = double_vec_create(4);
    for (int i = 0; i < 5; i++) double_vec_push(&dv, i * 1.5);
    printf("double_Vector: ");
    for (int i = 0; i < dv.size; i++) printf("%.1f ", dv.data[i]);
    printf("\n");
    double_vec_destroy(&dv);

    /* C11 _Generic */
    printf("\n--- C11 _Generic ---\n");
    printf("print_value(42) = "); print_value(42); printf("\n");
    printf("print_value(3.14) = "); print_value(3.14); printf("\n");
    printf("print_value(\"hello\") = "); print_value("hello"); printf("\n");
    printf("max_val(10, 20) = %d\n", max_val(10, 20));

    return 0;
}
