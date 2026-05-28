/*
 * Functions in C
 * Demonstrates: declaration, definition, pass-by-value, pass-by-pointer,
 *               function pointers, no overloading
 */
#include <stdio.h>

/* Forward declarations (prototypes) — required in C */
int add(int a, int b);
double add_double(double a, double b);  /* No overloading — must use different names */
void swap(int *a, int *b);              /* Pass by pointer for modification */
void apply(int arr[], int size, int (*func)(int));

/* Function definitions */
int add(int a, int b) {
    return a + b;
}

/* Cannot have another 'add' for doubles — must rename */
double add_double(double a, double b) {
    return a + b;
}

void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

/* Higher-order function using function pointer */
int double_it(int x) { return x * 2; }
int square_it(int x) { return x * x; }

void apply(int arr[], int size, int (*func)(int)) {
    for (int i = 0; i < size; i++) {
        arr[i] = func(arr[i]);
    }
}

/* No default arguments in C */
void print_line(const char *text, int width) {
    printf("%*s\n", width, text);  /* right-align to width */
}

/* Variadic functions (like printf) */
#include <stdarg.h>
int sum_all(int count, ...) {
    va_list args;
    va_start(args, count);
    int total = 0;
    for (int i = 0; i < count; i++) {
        total += va_arg(args, int);
    }
    va_end(args);
    return total;
}

int main(void) {
    printf("=== Functions in C ===\n\n");

    /* Basic calls */
    printf("add(3, 4) = %d\n", add(3, 4));
    printf("add_double(3.5, 4.2) = %.2f\n", add_double(3.5, 4.2));

    /* Pass by pointer */
    int x = 10, y = 20;
    printf("\nBefore swap: x=%d, y=%d\n", x, y);
    swap(&x, &y);
    printf("After swap:  x=%d, y=%d\n", x, y);

    /* Function pointers */
    int arr[] = {1, 2, 3, 4, 5};
    int n = 5;

    printf("\nOriginal: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);

    apply(arr, n, double_it);
    printf("\nDoubled:  ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);

    apply(arr, n, square_it);
    printf("\nSquared:  ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\n");

    /* Variadic function */
    printf("\nsum_all(3, 10, 20, 30) = %d\n", sum_all(3, 10, 20, 30));
    printf("sum_all(5, 1, 2, 3, 4, 5) = %d\n", sum_all(5, 1, 2, 3, 4, 5));

    return 0;
}
