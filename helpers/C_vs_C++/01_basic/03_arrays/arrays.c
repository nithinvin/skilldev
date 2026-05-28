/*
 * Arrays in C
 * Demonstrates: fixed arrays, passing to functions, 2D arrays
 */
#include <stdio.h>
#include <stdlib.h>

#define MAX_SIZE 10

/* Must pass size separately — array decays to pointer */
void print_array(int arr[], int size) {
    printf("[");
    for (int i = 0; i < size; i++) {
        printf("%d", arr[i]);
        if (i < size - 1) printf(", ");
    }
    printf("]\n");
}

int find_max(int arr[], int size) {
    int max = arr[0];
    for (int i = 1; i < size; i++) {
        if (arr[i] > max) max = arr[i];
    }
    return max;
}

void reverse_array(int arr[], int size) {
    for (int i = 0; i < size / 2; i++) {
        int temp = arr[i];
        arr[i] = arr[size - 1 - i];
        arr[size - 1 - i] = temp;
    }
}

int main(void) {
    /* Static array — size must be known at compile time (or VLA in C99) */
    int numbers[MAX_SIZE] = {64, 34, 25, 12, 22, 11, 90, 45, 78, 33};
    int size = MAX_SIZE;

    printf("Original array: ");
    print_array(numbers, size);

    printf("Maximum element: %d\n", find_max(numbers, size));

    reverse_array(numbers, size);
    printf("Reversed array: ");
    print_array(numbers, size);

    /* 2D Array */
    printf("\n--- 2D Array (Matrix) ---\n");
    int matrix[3][3] = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };

    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            printf("%3d ", matrix[i][j]);
        }
        printf("\n");
    }

    /* Dynamic array using malloc */
    printf("\n--- Dynamic Array ---\n");
    int n = 5;
    int *dynamic_arr = (int *)malloc(n * sizeof(int));
    if (dynamic_arr == NULL) {
        fprintf(stderr, "Memory allocation failed!\n");
        return 1;
    }

    for (int i = 0; i < n; i++) {
        dynamic_arr[i] = (i + 1) * 10;
    }
    print_array(dynamic_arr, n);

    /* Must manually free */
    free(dynamic_arr);

    return 0;
}
