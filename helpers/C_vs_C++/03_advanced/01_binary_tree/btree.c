/*
 * Binary Search Tree in C
 * Demonstrates: BST insert, search, delete, traversals (inorder, preorder, postorder, level-order)
 */
#include <stdio.h>
#include <stdlib.h>

typedef struct TreeNode {
    int data;
    struct TreeNode *left;
    struct TreeNode *right;
} TreeNode;

TreeNode* create_node(int data) {
    TreeNode *node = (TreeNode *)malloc(sizeof(TreeNode));
    node->data = data;
    node->left = node->right = NULL;
    return node;
}

TreeNode* bst_insert(TreeNode *root, int data) {
    if (root == NULL) return create_node(data);
    if (data < root->data)
        root->left = bst_insert(root->left, data);
    else if (data > root->data)
        root->right = bst_insert(root->right, data);
    return root;
}

TreeNode* find_min(TreeNode *node) {
    while (node->left != NULL) node = node->left;
    return node;
}

TreeNode* bst_delete(TreeNode *root, int data) {
    if (root == NULL) return NULL;

    if (data < root->data) {
        root->left = bst_delete(root->left, data);
    } else if (data > root->data) {
        root->right = bst_delete(root->right, data);
    } else {
        /* Node found */
        if (root->left == NULL) {
            TreeNode *temp = root->right;
            free(root);
            return temp;
        } else if (root->right == NULL) {
            TreeNode *temp = root->left;
            free(root);
            return temp;
        }
        /* Two children: replace with inorder successor */
        TreeNode *successor = find_min(root->right);
        root->data = successor->data;
        root->right = bst_delete(root->right, successor->data);
    }
    return root;
}

TreeNode* bst_search(TreeNode *root, int data) {
    if (root == NULL || root->data == data) return root;
    if (data < root->data) return bst_search(root->left, data);
    return bst_search(root->right, data);
}

/* Traversals */
void inorder(TreeNode *root) {
    if (root == NULL) return;
    inorder(root->left);
    printf("%d ", root->data);
    inorder(root->right);
}

void preorder(TreeNode *root) {
    if (root == NULL) return;
    printf("%d ", root->data);
    preorder(root->left);
    preorder(root->right);
}

void postorder(TreeNode *root) {
    if (root == NULL) return;
    postorder(root->left);
    postorder(root->right);
    printf("%d ", root->data);
}

/* Level-order traversal using a simple queue */
#define QUEUE_SIZE 100
void level_order(TreeNode *root) {
    if (root == NULL) return;
    TreeNode *queue[QUEUE_SIZE];
    int front = 0, rear = 0;

    queue[rear++] = root;
    while (front < rear) {
        TreeNode *current = queue[front++];
        printf("%d ", current->data);
        if (current->left) queue[rear++] = current->left;
        if (current->right) queue[rear++] = current->right;
    }
}

int tree_height(TreeNode *root) {
    if (root == NULL) return 0;
    int left_h = tree_height(root->left);
    int right_h = tree_height(root->right);
    return 1 + (left_h > right_h ? left_h : right_h);
}

int count_nodes(TreeNode *root) {
    if (root == NULL) return 0;
    return 1 + count_nodes(root->left) + count_nodes(root->right);
}

void tree_destroy(TreeNode *root) {
    if (root == NULL) return;
    tree_destroy(root->left);
    tree_destroy(root->right);
    free(root);
}

int main(void) {
    printf("=== Binary Search Tree in C ===\n\n");

    TreeNode *root = NULL;
    int values[] = {50, 30, 70, 20, 40, 60, 80, 10, 35, 65};
    int n = 10;

    for (int i = 0; i < n; i++) {
        root = bst_insert(root, values[i]);
    }

    printf("Inorder (sorted):  ");
    inorder(root);
    printf("\n");

    printf("Preorder:          ");
    preorder(root);
    printf("\n");

    printf("Postorder:         ");
    postorder(root);
    printf("\n");

    printf("Level-order:       ");
    level_order(root);
    printf("\n");

    printf("\nHeight: %d\n", tree_height(root));
    printf("Nodes: %d\n", count_nodes(root));

    /* Search */
    printf("\nSearch 40: %s\n", bst_search(root, 40) ? "Found" : "Not found");
    printf("Search 99: %s\n", bst_search(root, 99) ? "Found" : "Not found");

    /* Delete */
    printf("\nDelete 20 (leaf): ");
    root = bst_delete(root, 20);
    inorder(root);
    printf("\n");

    printf("Delete 30 (one child): ");
    root = bst_delete(root, 30);
    inorder(root);
    printf("\n");

    printf("Delete 50 (two children): ");
    root = bst_delete(root, 50);
    inorder(root);
    printf("\n");

    tree_destroy(root);
    return 0;
}
