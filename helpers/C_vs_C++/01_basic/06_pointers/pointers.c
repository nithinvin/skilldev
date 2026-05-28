/*
 * Pointers in C
 * Demonstrates: pointer basics, arrays & pointers, double pointers,
 *               pointer arithmetic, function pointers
 */
#include <stdio.h>
#include <stdlib.h>

void print_array_via_pointer(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", *(arr + i));  /* pointer arithmetic */
    }
    printf("\n");
}

/* Double pointer — to modify a pointer itself */
void allocate_array(int **ptr, int size) {
    *ptr = (int *)malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) {
        (*ptr)[i] = (i + 1) * 100;
    }
}

/* Function pointer example */
int ascending(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
}

int descending(const void *a, const void *b) {
    return (*(int *)b - *(int *)a);
}

int main(void) {
    printf("=== Pointers in C ===\n\n");

    /* Basic pointer operations */
    int x = 42;
    int *ptr = &x;

    printf("x = %d\n", x);
    printf("&x = %p\n", (void *)&x);
    printf("ptr = %p\n", (void *)ptr);
    printf("*ptr = %d\n", *ptr);

    *ptr = 100;  /* Modify x through pointer */
    printf("After *ptr = 100: x = %d\n\n", x);

    /* Array and pointer relationship */
    int arr[] = {10, 20, 30, 40, 50};
    int *aptr = arr;  /* Array name decays to pointer */

    printf("Array via pointer arithmetic:\n");
    for (int i = 0; i < 5; i++) {
        printf("  arr[%d] = %d, *(aptr+%d) = %d, address = %p\n",
               i, arr[i], i, *(aptr + i), (void *)(aptr + i));
    }

    /* Pointer to pointer (double pointer) */
    printf("\n--- Double Pointer ---\n");
    int *dynamic = NULL;
    allocate_array(&dynamic, 5);
    printf("Dynamically allocated: ");
    print_array_via_pointer(dynamic, 5);
    free(dynamic);

    /* Function pointers with qsort */
    printf("\n--- Function Pointers (qsort) ---\n");
    int numbers[] = {34, 7, 23, 32, 5, 62};
    int n = 6;

    qsort(numbers, n, sizeof(int), ascending);
    printf("Ascending:  ");
    print_array_via_pointer(numbers, n);

    qsort(numbers, n, sizeof(int), descending);
    printf("Descending: ");
    print_array_via_pointer(numbers, n);

    /* Void pointer — generic pointer */
    printf("\n--- Void Pointer ---\n");
    int ival = 42;
    float fval = 3.14f;
    void *vptr;

    vptr = &ival;
    printf("As int: %d\n", *(int *)vptr);

    vptr = &fval;
    printf("As float: %.2f\n", *(float *)vptr);

    /* Dangling pointer danger */
    /* int *dang = (int *)malloc(sizeof(int));
       free(dang);
       *dang = 10;  // UNDEFINED BEHAVIOR! */

    return 0;
}
