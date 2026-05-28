/*
 * Hash Table in C
 * Demonstrates: separate chaining, basic operations, string hashing
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 16

/* Key-Value pair node */
typedef struct Entry {
    char *key;
    int value;
    struct Entry *next;  /* Chaining for collision resolution */
} Entry;

typedef struct {
    Entry *buckets[TABLE_SIZE];
    int size;
} HashTable;

/* DJB2 hash function */
unsigned int hash_function(const char *key) {
    unsigned int hash = 5381;
    int c;
    while ((c = *key++)) {
        hash = ((hash << 5) + hash) + c;  /* hash * 33 + c */
    }
    return hash % TABLE_SIZE;
}

HashTable* ht_create(void) {
    HashTable *ht = (HashTable *)malloc(sizeof(HashTable));
    for (int i = 0; i < TABLE_SIZE; i++) {
        ht->buckets[i] = NULL;
    }
    ht->size = 0;
    return ht;
}

void ht_put(HashTable *ht, const char *key, int value) {
    unsigned int index = hash_function(key);
    Entry *current = ht->buckets[index];

    /* Check if key exists — update */
    while (current != NULL) {
        if (strcmp(current->key, key) == 0) {
            current->value = value;
            return;
        }
        current = current->next;
    }

    /* New entry — insert at head of chain */
    Entry *entry = (Entry *)malloc(sizeof(Entry));
    entry->key = strdup(key);
    entry->value = value;
    entry->next = ht->buckets[index];
    ht->buckets[index] = entry;
    ht->size++;
}

int ht_get(HashTable *ht, const char *key, int *value) {
    unsigned int index = hash_function(key);
    Entry *current = ht->buckets[index];

    while (current != NULL) {
        if (strcmp(current->key, key) == 0) {
            *value = current->value;
            return 1;  /* Found */
        }
        current = current->next;
    }
    return 0;  /* Not found */
}

int ht_delete(HashTable *ht, const char *key) {
    unsigned int index = hash_function(key);
    Entry *current = ht->buckets[index];
    Entry *prev = NULL;

    while (current != NULL) {
        if (strcmp(current->key, key) == 0) {
            if (prev == NULL) {
                ht->buckets[index] = current->next;
            } else {
                prev->next = current->next;
            }
            free(current->key);
            free(current);
            ht->size--;
            return 1;
        }
        prev = current;
        current = current->next;
    }
    return 0;
}

void ht_print(HashTable *ht) {
    printf("HashTable (size=%d):\n", ht->size);
    for (int i = 0; i < TABLE_SIZE; i++) {
        if (ht->buckets[i] != NULL) {
            printf("  [%2d]: ", i);
            Entry *current = ht->buckets[i];
            while (current) {
                printf("%s=%d", current->key, current->value);
                if (current->next) printf(" -> ");
                current = current->next;
            }
            printf("\n");
        }
    }
}

void ht_destroy(HashTable *ht) {
    for (int i = 0; i < TABLE_SIZE; i++) {
        Entry *current = ht->buckets[i];
        while (current) {
            Entry *next = current->next;
            free(current->key);
            free(current);
            current = next;
        }
    }
    free(ht);
}

/* Application: Word frequency counter */
void count_words(const char *text) {
    HashTable *freq = ht_create();
    char buffer[256];
    strcpy(buffer, text);

    char *word = strtok(buffer, " ,.!?;:");
    while (word != NULL) {
        int count = 0;
        ht_get(freq, word, &count);
        ht_put(freq, word, count + 1);
        word = strtok(NULL, " ,.!?;:");
    }

    printf("\nWord Frequencies:\n");
    ht_print(freq);
    ht_destroy(freq);
}

int main(void) {
    printf("=== Hash Table in C ===\n\n");

    HashTable *ht = ht_create();

    /* Insert */
    ht_put(ht, "Alice", 95);
    ht_put(ht, "Bob", 87);
    ht_put(ht, "Charlie", 92);
    ht_put(ht, "Diana", 88);
    ht_put(ht, "Eve", 91);

    ht_print(ht);

    /* Lookup */
    int val;
    printf("\nLookup 'Bob': ");
    if (ht_get(ht, "Bob", &val))
        printf("Found, value = %d\n", val);
    else
        printf("Not found\n");

    printf("Lookup 'Zara': ");
    if (ht_get(ht, "Zara", &val))
        printf("Found, value = %d\n", val);
    else
        printf("Not found\n");

    /* Update */
    ht_put(ht, "Bob", 90);
    ht_get(ht, "Bob", &val);
    printf("After update, Bob = %d\n", val);

    /* Delete */
    ht_delete(ht, "Charlie");
    printf("\nAfter deleting 'Charlie':\n");
    ht_print(ht);

    ht_destroy(ht);

    /* Application */
    printf("\n--- Word Frequency ---\n");
    count_words("the cat sat on the mat the cat likes the mat");

    return 0;
}
