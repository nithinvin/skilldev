/*
 * Error Handling in C
 * Demonstrates: return codes, errno, setjmp/longjmp, goto cleanup
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <setjmp.h>

/* ===== Approach 1: Return codes ===== */
typedef enum {
    SUCCESS = 0,
    ERR_NULL_PTR = -1,
    ERR_OUT_OF_MEMORY = -2,
    ERR_INVALID_INPUT = -3,
    ERR_FILE_NOT_FOUND = -4,
    ERR_OVERFLOW = -5
} ErrorCode;

const char* error_string(ErrorCode err) {
    switch (err) {
        case SUCCESS: return "Success";
        case ERR_NULL_PTR: return "Null pointer";
        case ERR_OUT_OF_MEMORY: return "Out of memory";
        case ERR_INVALID_INPUT: return "Invalid input";
        case ERR_FILE_NOT_FOUND: return "File not found";
        case ERR_OVERFLOW: return "Overflow";
        default: return "Unknown error";
    }
}

ErrorCode safe_divide(int a, int b, int *result) {
    if (result == NULL) return ERR_NULL_PTR;
    if (b == 0) return ERR_INVALID_INPUT;
    *result = a / b;
    return SUCCESS;
}

ErrorCode read_file_content(const char *filename, char **content) {
    FILE *fp = fopen(filename, "r");
    if (!fp) return ERR_FILE_NOT_FOUND;

    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    *content = (char *)malloc(size + 1);
    if (!*content) {
        fclose(fp);
        return ERR_OUT_OF_MEMORY;
    }

    fread(*content, 1, size, fp);
    (*content)[size] = '\0';
    fclose(fp);
    return SUCCESS;
}

/* ===== Approach 2: errno ===== */
void demo_errno(void) {
    printf("\n--- errno demo ---\n");
    FILE *fp = fopen("/nonexistent/file.txt", "r");
    if (fp == NULL) {
        printf("fopen failed: %s (errno=%d)\n", strerror(errno), errno);
    }

    char *endptr;
    errno = 0;
    long val = strtol("99999999999999999999", &endptr, 10);
    if (errno == ERANGE) {
        printf("strtol overflow: %s\n", strerror(errno));
    }
    (void)val;
}

/* ===== Approach 3: goto cleanup pattern ===== */
ErrorCode complex_operation(const char *filename) {
    FILE *fp = NULL;
    char *buffer = NULL;
    int *data = NULL;
    ErrorCode err = SUCCESS;

    fp = fopen(filename, "r");
    if (!fp) { err = ERR_FILE_NOT_FOUND; goto cleanup; }

    buffer = (char *)malloc(1024);
    if (!buffer) { err = ERR_OUT_OF_MEMORY; goto cleanup; }

    data = (int *)malloc(100 * sizeof(int));
    if (!data) { err = ERR_OUT_OF_MEMORY; goto cleanup; }

    /* Process... */
    printf("  Processing %s... (simulated success)\n", filename);

cleanup:
    /* All resources freed regardless of where we failed */
    if (data) free(data);
    if (buffer) free(buffer);
    if (fp) fclose(fp);
    return err;
}

/* ===== Approach 4: setjmp/longjmp (non-local goto) ===== */
static jmp_buf jump_buffer;

void risky_function(int value) {
    if (value < 0) {
        longjmp(jump_buffer, 1);  /* "throw" */
    }
    if (value == 0) {
        longjmp(jump_buffer, 2);  /* Different "exception" */
    }
    printf("  risky_function(%d) succeeded\n", value);
}

int main(void) {
    printf("=== Error Handling in C ===\n\n");

    /* Return codes */
    printf("--- Return Codes ---\n");
    int result;
    ErrorCode err;

    err = safe_divide(10, 3, &result);
    if (err == SUCCESS)
        printf("10 / 3 = %d\n", result);

    err = safe_divide(10, 0, &result);
    if (err != SUCCESS)
        printf("10 / 0 failed: %s\n", error_string(err));

    err = safe_divide(10, 3, NULL);
    if (err != SUCCESS)
        printf("null result failed: %s\n", error_string(err));

    /* errno */
    demo_errno();

    /* goto cleanup */
    printf("\n--- goto cleanup pattern ---\n");
    err = complex_operation("test.txt");
    printf("  Result: %s\n", error_string(err));

    /* setjmp/longjmp */
    printf("\n--- setjmp/longjmp ---\n");
    int jmp_val = setjmp(jump_buffer);
    if (jmp_val == 0) {
        /* Normal execution */
        risky_function(5);
        risky_function(-1);  /* Will "throw" */
        risky_function(3);   /* Never reached */
    } else {
        /* "Caught" */
        printf("  Caught exception code: %d\n", jmp_val);
    }

    return 0;
}
