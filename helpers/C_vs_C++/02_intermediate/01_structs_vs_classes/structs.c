/*
 * Structs in C
 * Demonstrates: struct definition, typedef, function pointers for "methods"
 */
#include <stdio.h>
#include <string.h>
#include <math.h>

/* Basic struct */
typedef struct {
    char name[50];
    int age;
    float gpa;
    char department[30];
} Student;

/* Constructor-like function */
Student create_student(const char *name, int age, float gpa, const char *dept) {
    Student s;
    strncpy(s.name, name, sizeof(s.name) - 1);
    s.name[sizeof(s.name) - 1] = '\0';
    s.age = age;
    s.gpa = gpa;
    strncpy(s.department, dept, sizeof(s.department) - 1);
    s.department[sizeof(s.department) - 1] = '\0';
    return s;
}

void print_student(const Student *s) {
    printf("Name: %s, Age: %d, GPA: %.2f, Dept: %s\n",
           s->name, s->age, s->gpa, s->department);
}

/* Struct with "methods" via function pointers */
typedef struct Shape Shape;
struct Shape {
    double param1;
    double param2;
    double (*area)(const Shape *self);
    const char *type;
};

double circle_area(const Shape *self) {
    return M_PI * self->param1 * self->param1;
}

double rectangle_area(const Shape *self) {
    return self->param1 * self->param2;
}

Shape create_circle(double radius) {
    Shape s = {radius, 0, circle_area, "Circle"};
    return s;
}

Shape create_rectangle(double width, double height) {
    Shape s = {width, height, rectangle_area, "Rectangle"};
    return s;
}

/* Nested structs */
typedef struct {
    int day, month, year;
} Date;

typedef struct {
    char title[100];
    char author[50];
    Date published;
    int pages;
} Book;

int main(void) {
    printf("=== Structs in C ===\n\n");

    /* Student struct */
    Student s1 = create_student("Nithin", 19, 8.5, "CSE");
    Student s2 = create_student("Alice", 20, 9.1, "ECE");

    print_student(&s1);
    print_student(&s2);

    /* Array of structs */
    Student class_[3] = {
        {"Bob", 19, 7.8, "CSE"},
        {"Charlie", 20, 8.2, "IT"},
        {"Diana", 19, 9.0, "CSE"}
    };

    printf("\n--- Class List ---\n");
    for (int i = 0; i < 3; i++) {
        print_student(&class_[i]);
    }

    /* Polymorphism via function pointers */
    printf("\n--- Shapes (Polymorphism via function pointers) ---\n");
    Shape shapes[] = {
        create_circle(5.0),
        create_rectangle(4.0, 6.0),
        create_circle(3.0)
    };

    for (int i = 0; i < 3; i++) {
        printf("%s: area = %.2f\n", shapes[i].type, shapes[i].area(&shapes[i]));
    }

    /* Nested struct */
    printf("\n--- Nested Struct ---\n");
    Book b = {"The C Programming Language", "Kernighan & Ritchie", {22, 2, 1978}, 228};
    printf("'%s' by %s (%d/%d/%d), %d pages\n",
           b.title, b.author, b.published.day, b.published.month,
           b.published.year, b.pages);

    return 0;
}
