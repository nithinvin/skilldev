/*
 * Classes in C++
 * Demonstrates: encapsulation, constructors, inheritance, polymorphism, operator overloading
 */
#include <iostream>
#include <string>
#include <vector>
#include <cmath>
using namespace std;

// Class with encapsulation
class Student {
private:
    string name;
    int age;
    double gpa;
    string department;

public:
    // Constructor
    Student(const string& name, int age, double gpa, const string& dept)
        : name(name), age(age), gpa(gpa), department(dept) {}

    // Default constructor
    Student() : name("Unknown"), age(0), gpa(0.0), department("Unassigned") {}

    // Getters
    string getName() const { return name; }
    double getGpa() const { return gpa; }

    // Method
    void print() const {
        cout << "Name: " << name << ", Age: " << age
             << ", GPA: " << gpa << ", Dept: " << department << endl;
    }

    // Operator overloading — compare by GPA
    bool operator>(const Student& other) const {
        return gpa > other.gpa;
    }

    // Friend function for stream output
    friend ostream& operator<<(ostream& os, const Student& s) {
        os << s.name << " (GPA: " << s.gpa << ")";
        return os;
    }
};

// Inheritance and Polymorphism
class Shape {
protected:
    string type;
public:
    Shape(const string& t) : type(t) {}
    virtual ~Shape() = default;  // Virtual destructor for proper cleanup

    // Pure virtual function — makes Shape abstract
    virtual double area() const = 0;

    string getType() const { return type; }

    // Virtual function with default implementation
    virtual void describe() const {
        cout << type << ": area = " << area() << endl;
    }
};

class Circle : public Shape {
private:
    double radius;
public:
    Circle(double r) : Shape("Circle"), radius(r) {}
    double area() const override { return M_PI * radius * radius; }
};

class Rectangle : public Shape {
private:
    double width, height;
public:
    Rectangle(double w, double h) : Shape("Rectangle"), width(w), height(h) {}
    double area() const override { return width * height; }
};

class Triangle : public Shape {
private:
    double base, height;
public:
    Triangle(double b, double h) : Shape("Triangle"), base(b), height(h) {}
    double area() const override { return 0.5 * base * height; }
};

// Nested class example
class Book {
public:
    struct Date {
        int day, month, year;
        string toString() const {
            return to_string(day) + "/" + to_string(month) + "/" + to_string(year);
        }
    };

private:
    string title, author;
    Date published;
    int pages;

public:
    Book(const string& t, const string& a, Date d, int p)
        : title(t), author(a), published(d), pages(p) {}

    void print() const {
        cout << "'" << title << "' by " << author
             << " (" << published.toString() << "), " << pages << " pages" << endl;
    }
};

int main() {
    cout << "=== Classes in C++ ===" << endl << endl;

    // Students
    Student s1("Nithin", 19, 8.5, "CSE");
    Student s2("Alice", 20, 9.1, "ECE");
    s1.print();
    s2.print();

    // Operator overloading
    cout << "\nWho has higher GPA? " << (s1 > s2 ? s1 : s2) << endl;

    // Vector of students
    vector<Student> class_list = {
        {"Bob", 19, 7.8, "CSE"},
        {"Charlie", 20, 8.2, "IT"},
        {"Diana", 19, 9.0, "CSE"}
    };

    cout << "\n--- Class List ---" << endl;
    for (const auto& s : class_list) {
        s.print();
    }

    // Polymorphism — virtual functions
    cout << "\n--- Shapes (Polymorphism via virtual functions) ---" << endl;
    vector<unique_ptr<Shape>> shapes;
    shapes.push_back(make_unique<Circle>(5.0));
    shapes.push_back(make_unique<Rectangle>(4.0, 6.0));
    shapes.push_back(make_unique<Triangle>(3.0, 8.0));
    shapes.push_back(make_unique<Circle>(3.0));

    for (const auto& shape : shapes) {
        shape->describe();  // Virtual dispatch — correct area() called
    }

    // Total area using algorithm
    double total = 0;
    for (const auto& s : shapes) total += s->area();
    cout << "Total area: " << total << endl;

    // Nested class
    cout << "\n--- Nested Class ---" << endl;
    Book b("The C++ Programming Language", "Bjarne Stroustrup", {1, 1, 2013}, 1368);
    b.print();

    return 0;
}
