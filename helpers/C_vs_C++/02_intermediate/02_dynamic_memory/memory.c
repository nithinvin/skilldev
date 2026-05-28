/*
 * Dynamic Memory in C
 * Demonstrates: malloc, calloc, realloc, free, memory management patterns
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Dynamic string (growable buffer) */
typedef struct {
    char *data;
    size_t length;
    size_t capacity;
} DynamicString;

DynamicString* ds_create(size_t initial_cap) {
    DynamicString *ds = (DynamicString *)malloc(sizeof(DynamicString));
    if (!ds) return NULL;
    ds->data = (char *)malloc(initial_cap);
    if (!ds->data) { free(ds); return NULL; }
    ds->data[0] = '\0';
    ds->length = 0;
    ds->capacity = initial_cap;
    return ds;
}

int ds_append(DynamicString *ds, const char *text) {
    size_t text_len = strlen(text);
    if (ds->length + text_len + 1 > ds->capacity) {
        size_t new_cap = (ds->length + text_len + 1) * 2;
        char *new_data = (char *)realloc(ds->data, new_cap);
        if (!new_data) return -1;  /* allocation failed */
        ds->data = new_data;
        ds->capacity = new_cap;
    }
    strcat(ds->data, text);
    ds->length += text_len;
    return 0;
}

void ds_destroy(DynamicString *ds) {
    if (ds) {
        free(ds->data);
        free(ds);
    }
}

/* Dynamic 2D array */
int** create_2d_array(int rows, int cols) {
    int **arr = (int **)malloc(rows * sizeof(int *));
    if (!arr) return NULL;
    for (int i = 0; i < rows; i++) {
        arr[i] = (int *)calloc(cols, sizeof(int));  /* calloc zeros memory */
        if (!arr[i]) {
            /* Cleanup on failure */
            for (int j = 0; j < i; j++) free(arr[j]);
            free(arr);
            return NULL;
        }
    }
    return arr;
}

void free_2d_array(int **arr, int rows) {
    for (int i = 0; i < rows; i++) {
        free(arr[i]);
    }
    free(arr);
}

int main(void) {
    printf("=== Dynamic Memory in C ===\n\n");

    /* Basic malloc/free */
    int *ptr = (int *)malloc(sizeof(int));
    if (ptr == NULL) {
        fprintf(stderr, "malloc failed!\n");
        return 1;
    }
    *ptr = 42;
    printf("malloc'd value: %d\n", *ptr);
    free(ptr);
    ptr = NULL;  /* Avoid dangling pointer */

    /* Dynamic array with realloc */
    printf("\n--- Dynamic Array (realloc) ---\n");
    int size = 5;
    int *arr = (int *)malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) arr[i] = i * 10;

    printf("Before realloc (%d elements): ", size);
    for (int i = 0; i < size; i++) printf("%d ", arr[i]);
    printf("\n");

    /* Grow the array */
    size = 10;
    int *temp = (int *)realloc(arr, size * sizeof(int));
    if (temp == NULL) {
        free(arr);  /* Original still valid if realloc fails */
        return 1;
    }
    arr = temp;
    for (int i = 5; i < size; i++) arr[i] = i * 10;

    printf("After realloc (%d elements): ", size);
    for (int i = 0; i < size; i++) printf("%d ", arr[i]);
    printf("\n");
    free(arr);

    /* Dynamic string */
    printf("\n--- Dynamic String ---\n");
    DynamicString *ds = ds_create(16);
    ds_append(ds, "Hello");
    ds_append(ds, ", ");
    ds_append(ds, "Dynamic");
    ds_append(ds, " World!");
    printf("String: \"%s\" (len=%zu, cap=%zu)\n", ds->data, ds->length, ds->capacity);
    ds_destroy(ds);

    /* 2D Dynamic array */
    printf("\n--- 2D Dynamic Array ---\n");
    int rows = 3, cols = 4;
    int **matrix = create_2d_array(rows, cols);
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            matrix[i][j] = i * cols + j;

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++)
            printf("%3d ", matrix[i][j]);
        printf("\n");
    }
    free_2d_array(matrix, rows);

    return 0;
}
