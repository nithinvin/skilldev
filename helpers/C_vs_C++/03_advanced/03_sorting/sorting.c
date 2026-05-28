/*
 * Sorting in C
 * Demonstrates: bubble sort, merge sort, qsort with function pointers
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void print_array(int arr[], int n) {
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\n");
}

/* Bubble Sort - O(n^2) */
void bubble_sort(int arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        int swapped = 0;
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
                swapped = 1;
            }
        }
        if (!swapped) break;  /* Optimization: already sorted */
    }
}

/* Merge Sort - O(n log n) */
void merge(int arr[], int left, int mid, int right) {
    int n1 = mid - left + 1;
    int n2 = right - mid;

    int *L = (int *)malloc(n1 * sizeof(int));
    int *R = (int *)malloc(n2 * sizeof(int));

    memcpy(L, arr + left, n1 * sizeof(int));
    memcpy(R, arr + mid + 1, n2 * sizeof(int));

    int i = 0, j = 0, k = left;
    while (i < n1 && j < n2) {
        if (L[i] <= R[j]) arr[k++] = L[i++];
        else arr[k++] = R[j++];
    }
    while (i < n1) arr[k++] = L[i++];
    while (j < n2) arr[k++] = R[j++];

    free(L);
    free(R);
}

void merge_sort(int arr[], int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        merge_sort(arr, left, mid);
        merge_sort(arr, mid + 1, right);
        merge(arr, left, mid, right);
    }
}

/* qsort comparators */
int compare_asc(const void *a, const void *b) {
    return (*(int *)a - *(int *)b);
}

int compare_desc(const void *a, const void *b) {
    return (*(int *)b - *(int *)a);
}

/* Sorting structs */
typedef struct {
    char name[30];
    int score;
} Student;

int compare_by_score(const void *a, const void *b) {
    return ((Student *)b)->score - ((Student *)a)->score;
}

int compare_by_name(const void *a, const void *b) {
    return strcmp(((Student *)a)->name, ((Student *)b)->name);
}

int main(void) {
    printf("=== Sorting in C ===\n\n");

    /* Bubble Sort */
    int arr1[] = {64, 34, 25, 12, 22, 11, 90};
    int n = 7;
    printf("Bubble Sort:\n  Before: ");
    print_array(arr1, n);
    bubble_sort(arr1, n);
    printf("  After:  ");
    print_array(arr1, n);

    /* Merge Sort */
    int arr2[] = {38, 27, 43, 3, 9, 82, 10};
    printf("\nMerge Sort:\n  Before: ");
    print_array(arr2, n);
    merge_sort(arr2, 0, n - 1);
    printf("  After:  ");
    print_array(arr2, n);

    /* qsort — C standard library */
    int arr3[] = {5, 2, 8, 1, 9, 3, 7, 4, 6};
    int n3 = 9;
    printf("\nqsort (ascending):\n  Before: ");
    print_array(arr3, n3);
    qsort(arr3, n3, sizeof(int), compare_asc);
    printf("  After:  ");
    print_array(arr3, n3);

    qsort(arr3, n3, sizeof(int), compare_desc);
    printf("  Desc:   ");
    print_array(arr3, n3);

    /* Sorting structs */
    printf("\n--- Sorting Structs ---\n");
    Student students[] = {
        {"Charlie", 85},
        {"Alice", 92},
        {"Bob", 78},
        {"Diana", 95},
        {"Eve", 88}
    };
    int ns = 5;

    qsort(students, ns, sizeof(Student), compare_by_score);
    printf("By score (desc):\n");
    for (int i = 0; i < ns; i++)
        printf("  %s: %d\n", students[i].name, students[i].score);

    qsort(students, ns, sizeof(Student), compare_by_name);
    printf("By name (asc):\n");
    for (int i = 0; i < ns; i++)
        printf("  %s: %d\n", students[i].name, students[i].score);

    return 0;
}
