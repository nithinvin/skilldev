/*
 * File I/O in C
 * Demonstrates: fopen, fclose, fprintf, fscanf, fread, fwrite, fseek
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int id;
    char name[50];
    float score;
} Record;

int main(void) {
    printf("=== File I/O in C ===\n\n");

    /* Text file writing */
    printf("--- Writing text file ---\n");
    FILE *fp = fopen("output_c.txt", "w");
    if (fp == NULL) {
        perror("Error opening file");
        return 1;
    }
    fprintf(fp, "Student Records\n");
    fprintf(fp, "================\n");
    fprintf(fp, "%-5s %-20s %s\n", "ID", "Name", "Score");
    fprintf(fp, "%-5d %-20s %.1f\n", 1, "Alice", 95.5);
    fprintf(fp, "%-5d %-20s %.1f\n", 2, "Bob", 87.3);
    fprintf(fp, "%-5d %-20s %.1f\n", 3, "Charlie", 92.0);
    fclose(fp);
    printf("Written to output_c.txt\n");

    /* Text file reading */
    printf("\n--- Reading text file ---\n");
    fp = fopen("output_c.txt", "r");
    if (fp == NULL) {
        perror("Error opening file");
        return 1;
    }
    char line[256];
    while (fgets(line, sizeof(line), fp) != NULL) {
        printf("  %s", line);
    }
    fclose(fp);

    /* Binary file writing */
    printf("\n--- Writing binary file ---\n");
    Record records[] = {
        {1, "Alice", 95.5f},
        {2, "Bob", 87.3f},
        {3, "Charlie", 92.0f}
    };
    int num_records = 3;

    fp = fopen("records_c.bin", "wb");
    if (fp == NULL) {
        perror("Error opening binary file");
        return 1;
    }
    fwrite(&num_records, sizeof(int), 1, fp);
    fwrite(records, sizeof(Record), num_records, fp);
    fclose(fp);
    printf("Written %d records to records_c.bin\n", num_records);

    /* Binary file reading */
    printf("\n--- Reading binary file ---\n");
    fp = fopen("records_c.bin", "rb");
    if (fp == NULL) {
        perror("Error opening binary file");
        return 1;
    }
    int count;
    fread(&count, sizeof(int), 1, fp);
    printf("Number of records: %d\n", count);

    Record *loaded = (Record *)malloc(count * sizeof(Record));
    fread(loaded, sizeof(Record), count, fp);
    fclose(fp);

    for (int i = 0; i < count; i++) {
        printf("  ID: %d, Name: %s, Score: %.1f\n",
               loaded[i].id, loaded[i].name, loaded[i].score);
    }
    free(loaded);

    /* Append mode */
    printf("\n--- Appending to file ---\n");
    fp = fopen("output_c.txt", "a");
    fprintf(fp, "%-5d %-20s %.1f\n", 4, "Diana", 88.7);
    fclose(fp);
    printf("Appended Diana's record\n");

    /* Cleanup */
    remove("output_c.txt");
    remove("records_c.bin");

    return 0;
}
