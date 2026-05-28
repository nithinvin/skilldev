/*
 * Strings in C
 * Demonstrates: char arrays, string.h functions, common pitfalls
 */
#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main(void) {
    /* Strings are null-terminated char arrays */
    char greeting[50] = "Hello";
    char name[50];
    char result[100];

    printf("=== String Operations in C ===\n\n");

    /* String length */
    printf("greeting = \"%s\"\n", greeting);
    printf("Length: %zu\n", strlen(greeting));

    /* String copy */
    strcpy(name, "World");
    printf("name = \"%s\"\n", name);

    /* String concatenation */
    strcpy(result, greeting);
    strcat(result, ", ");
    strcat(result, name);
    strcat(result, "!");
    printf("Concatenated: \"%s\"\n", result);

    /* String comparison */
    char s1[] = "apple";
    char s2[] = "banana";
    int cmp = strcmp(s1, s2);
    if (cmp < 0)
        printf("\"%s\" comes before \"%s\"\n", s1, s2);
    else if (cmp > 0)
        printf("\"%s\" comes after \"%s\"\n", s1, s2);
    else
        printf("\"%s\" equals \"%s\"\n", s1, s2);

    /* Substring search */
    char haystack[] = "Data Structures and Algorithms";
    char *found = strstr(haystack, "Struct");
    if (found)
        printf("Found 'Struct' at position: %ld\n", found - haystack);

    /* Character-by-character operations */
    char sentence[] = "hello world 123";
    printf("\nOriginal: \"%s\"\n", sentence);
    printf("Uppercase: \"");
    for (int i = 0; sentence[i] != '\0'; i++) {
        putchar(toupper(sentence[i]));
    }
    printf("\"\n");

    /* Tokenization (splitting) */
    char csv[] = "VIT,Chennai,CSE,2024";
    printf("\nTokenizing \"%s\":\n", csv);
    char *token = strtok(csv, ",");
    while (token != NULL) {
        printf("  -> %s\n", token);
        token = strtok(NULL, ",");
    }
    /* WARNING: strtok modifies the original string! */

    /* Buffer overflow danger */
    char small[5];
    /* strcpy(small, "This is way too long!"); -- BUFFER OVERFLOW! */
    strncpy(small, "Hi!", sizeof(small) - 1);
    small[sizeof(small) - 1] = '\0';  /* Always null-terminate */
    printf("\nSafe copy: \"%s\"\n", small);

    return 0;
}
