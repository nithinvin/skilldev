/*
 * Resource Management in C
 * Demonstrates: goto cleanup, nested resource acquisition, common patterns
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ===== The Problem: Multiple Resources ===== */

typedef struct {
    char *name;
    FILE *log_file;
    int *buffer;
    int buffer_size;
} Context;

/* The "goto cleanup" pattern — C's best practice */
Context* context_create(const char *name, const char *log_path, int buf_size) {
    Context *ctx = NULL;

    ctx = (Context *)malloc(sizeof(Context));
    if (!ctx) goto fail;

    ctx->name = strdup(name);
    if (!ctx->name) goto fail;

    ctx->log_file = fopen(log_path, "w");
    if (!ctx->log_file) goto fail;

    ctx->buffer = (int *)malloc(buf_size * sizeof(int));
    if (!ctx->buffer) goto fail;

    ctx->buffer_size = buf_size;
    fprintf(ctx->log_file, "Context '%s' created successfully\n", name);
    return ctx;

fail:
    /* Cleanup in reverse order of acquisition */
    if (ctx) {
        if (ctx->buffer) free(ctx->buffer);
        if (ctx->log_file) fclose(ctx->log_file);
        if (ctx->name) free(ctx->name);
        free(ctx);
    }
    return NULL;
}

void context_use(Context *ctx) {
    if (!ctx) return;
    fprintf(ctx->log_file, "Using context '%s'\n", ctx->name);
    for (int i = 0; i < ctx->buffer_size; i++) {
        ctx->buffer[i] = i * i;
    }
    printf("Context '%s' used: buffer[0..4] = %d, %d, %d, %d, %d\n",
           ctx->name, ctx->buffer[0], ctx->buffer[1], ctx->buffer[2],
           ctx->buffer[3], ctx->buffer[4]);
}

void context_destroy(Context *ctx) {
    if (!ctx) return;
    fprintf(ctx->log_file, "Context '%s' destroying\n", ctx->name);
    free(ctx->buffer);
    fclose(ctx->log_file);
    free(ctx->name);
    free(ctx);
    printf("Context destroyed and all resources freed\n");
}

/* ===== Multi-resource function with cleanup ===== */
int process_files(const char *input_path, const char *output_path) {
    int result = -1;
    FILE *input = NULL;
    FILE *output = NULL;
    char *buffer = NULL;

    input = fopen(input_path, "r");
    if (!input) {
        fprintf(stderr, "Cannot open input: %s\n", input_path);
        goto cleanup;
    }

    output = fopen(output_path, "w");
    if (!output) {
        fprintf(stderr, "Cannot open output: %s\n", output_path);
        goto cleanup;
    }

    buffer = (char *)malloc(4096);
    if (!buffer) {
        fprintf(stderr, "Out of memory\n");
        goto cleanup;
    }

    /* Process file content */
    while (fgets(buffer, 4096, input)) {
        /* Transform and write */
        for (int i = 0; buffer[i]; i++) {
            if (buffer[i] >= 'a' && buffer[i] <= 'z')
                buffer[i] -= 32;  /* To uppercase */
        }
        fputs(buffer, output);
    }

    result = 0;  /* Success */

cleanup:
    if (buffer) free(buffer);
    if (output) fclose(output);
    if (input) fclose(input);
    return result;
}

/* ===== Callback-based resource management ===== */
typedef void (*CleanupFunc)(void *);

typedef struct {
    void *resources[10];
    CleanupFunc cleaners[10];
    int count;
} CleanupStack;

void cleanup_push(CleanupStack *cs, void *resource, CleanupFunc cleaner) {
    cs->resources[cs->count] = resource;
    cs->cleaners[cs->count] = cleaner;
    cs->count++;
}

void cleanup_all(CleanupStack *cs) {
    /* Clean in reverse order */
    for (int i = cs->count - 1; i >= 0; i--) {
        if (cs->resources[i]) {
            cs->cleaners[i](cs->resources[i]);
        }
    }
    cs->count = 0;
}

void free_wrapper(void *p) { free(p); }
void fclose_wrapper(void *p) { fclose((FILE *)p); }

int main(void) {
    printf("=== Resource Management in C ===\n\n");

    /* Context pattern */
    printf("--- Context (goto cleanup) ---\n");
    Context *ctx = context_create("TestContext", "/tmp/test_c_raii.log", 10);
    if (ctx) {
        context_use(ctx);
        context_destroy(ctx);
    }

    /* Process files */
    printf("\n--- Multi-resource cleanup ---\n");
    /* Create a test input file */
    FILE *tmp = fopen("/tmp/input_c.txt", "w");
    fprintf(tmp, "hello world\nfrom c program\n");
    fclose(tmp);

    int ret = process_files("/tmp/input_c.txt", "/tmp/output_c.txt");
    printf("process_files result: %s\n", ret == 0 ? "success" : "failed");

    /* Read back */
    FILE *out = fopen("/tmp/output_c.txt", "r");
    if (out) {
        char line[256];
        printf("Output:\n");
        while (fgets(line, sizeof(line), out)) printf("  %s", line);
        fclose(out);
    }

    /* Cleanup stack approach */
    printf("\n--- Cleanup Stack (manual RAII) ---\n");
    CleanupStack cs = {.count = 0};

    int *arr = (int *)malloc(100 * sizeof(int));
    cleanup_push(&cs, arr, free_wrapper);

    char *str = strdup("Hello, cleanup!");
    cleanup_push(&cs, str, free_wrapper);

    printf("Resources acquired: %d\n", cs.count);
    cleanup_all(&cs);
    printf("All resources cleaned up\n");

    /* Remove temp files */
    remove("/tmp/test_c_raii.log");
    remove("/tmp/input_c.txt");
    remove("/tmp/output_c.txt");

    return 0;
}
