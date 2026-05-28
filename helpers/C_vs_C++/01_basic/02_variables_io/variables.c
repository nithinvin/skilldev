/*
 * Variables and I/O in C
 * Demonstrates: data types, scanf, printf formatting
 */
#include <stdio.h>

int main(void) {
    /* Variable declarations must be at the top in C89 */
    int age;
    float gpa;
    char name[50];
    char grade;

    printf("=== Student Information System (C) ===\n\n");

    printf("Enter your name: ");
    scanf("%49s", name);  /* %49s to prevent buffer overflow */

    printf("Enter your age: ");
    scanf("%d", &age);

    printf("Enter your GPA (out of 10): ");
    scanf("%f", &gpa);

    printf("Enter your grade (A/B/C/D): ");
    scanf(" %c", &grade);  /* space before %c to skip whitespace */

    printf("\n--- Summary ---\n");
    printf("Name  : %s\n", name);
    printf("Age   : %d years\n", age);
    printf("GPA   : %.2f / 10.0\n", gpa);
    printf("Grade : %c\n", grade);

    /* Type sizes */
    printf("\n--- Type Sizes ---\n");
    printf("int   : %zu bytes\n", sizeof(int));
    printf("float : %zu bytes\n", sizeof(float));
    printf("double: %zu bytes\n", sizeof(double));
    printf("char  : %zu bytes\n", sizeof(char));

    return 0;
}
