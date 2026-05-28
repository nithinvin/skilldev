/*
 * Variables and I/O in C++
 * Demonstrates: auto, string, cin/cout, type inference
 */
#include <iostream>
#include <string>
using namespace std;

int main() {
    // Variables can be declared anywhere in C++
    cout << "=== Student Information System (C++) ===" << endl << endl;

    cout << "Enter your name: ";
    string name;
    getline(cin, name);  // Reads full line including spaces

    cout << "Enter your age: ";
    int age;
    cin >> age;

    cout << "Enter your GPA (out of 10): ";
    double gpa;  // C++ prefers double over float
    cin >> gpa;

    cout << "Enter your grade (A/B/C/D): ";
    char grade;
    cin >> grade;

    cout << "\n--- Summary ---" << endl;
    cout << "Name  : " << name << endl;
    cout << "Age   : " << age << " years" << endl;
    cout << "GPA   : " << fixed << gpa << " / 10.0" << endl;  // fixed precision
    cout << "Grade : " << grade << endl;

    // C++11: auto keyword for type inference
    auto pi = 3.14159;        // deduced as double
    auto count = 42;          // deduced as int
    auto message = "hello"s;  // deduced as std::string (with s literal)

    cout << "\n--- Type Sizes ---" << endl;
    cout << "int    : " << sizeof(int) << " bytes" << endl;
    cout << "float  : " << sizeof(float) << " bytes" << endl;
    cout << "double : " << sizeof(double) << " bytes" << endl;
    cout << "char   : " << sizeof(char) << " bytes" << endl;
    cout << "string : " << sizeof(string) << " bytes (object size, not content)" << endl;

    // C++11: uniform initialization
    int x{10};         // brace initialization prevents narrowing
    // int y{3.14};    // ERROR! narrowing conversion not allowed

    cout << "\nBrace-initialized x = " << x << endl;

    return 0;
}
