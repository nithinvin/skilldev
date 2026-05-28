/*
 * Stack in C++
 * Demonstrates: custom stack class + std::stack, applications
 */
#include <iostream>
#include <stack>
#include <string>
#include <vector>
#include <sstream>
using namespace std;

// Custom template stack
template <typename T>
class Stack {
private:
    vector<T> data;  // Use vector as underlying storage

public:
    void push(const T& value) { data.push_back(value); }

    T pop() {
        if (data.empty()) throw runtime_error("Stack underflow!");
        T val = data.back();
        data.pop_back();
        return val;
    }

    const T& top() const {
        if (data.empty()) throw runtime_error("Stack is empty!");
        return data.back();
    }

    bool empty() const { return data.empty(); }
    size_t size() const { return data.size(); }
};

// Application: Balanced Parentheses
bool check_balanced(const string& expr) {
    stack<char> s;
    for (char ch : expr) {
        if (ch == '(' || ch == '[' || ch == '{') {
            s.push(ch);
        } else if (ch == ')' || ch == ']' || ch == '}') {
            if (s.empty()) return false;
            char top = s.top(); s.pop();
            if ((ch == ')' && top != '(') ||
                (ch == ']' && top != '[') ||
                (ch == '}' && top != '{'))
                return false;
        }
    }
    return s.empty();
}

// Application: Postfix Expression Evaluation
int evaluate_postfix(const string& expr) {
    stack<int> s;
    istringstream iss(expr);
    string token;

    while (iss >> token) {
        if (token == "+" || token == "-" || token == "*" || token == "/") {
            int b = s.top(); s.pop();
            int a = s.top(); s.pop();
            if (token == "+") s.push(a + b);
            else if (token == "-") s.push(a - b);
            else if (token == "*") s.push(a * b);
            else if (token == "/") s.push(a / b);
        } else {
            s.push(stoi(token));
        }
    }
    return s.top();
}

// Application: Infix to Postfix conversion
int precedence(char op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
}

string infix_to_postfix(const string& expr) {
    stack<char> ops;
    string result;

    for (char ch : expr) {
        if (isdigit(ch)) {
            result += ch;
            result += ' ';
        } else if (ch == '(') {
            ops.push(ch);
        } else if (ch == ')') {
            while (!ops.empty() && ops.top() != '(') {
                result += ops.top(); result += ' ';
                ops.pop();
            }
            ops.pop();  // Remove '('
        } else if (ch == '+' || ch == '-' || ch == '*' || ch == '/') {
            while (!ops.empty() && precedence(ops.top()) >= precedence(ch)) {
                result += ops.top(); result += ' ';
                ops.pop();
            }
            ops.push(ch);
        }
    }
    while (!ops.empty()) {
        result += ops.top(); result += ' ';
        ops.pop();
    }
    return result;
}

int main() {
    cout << "=== Stack in C++ ===" << endl;

    // Custom stack
    cout << "\n--- Custom Stack<int> ---" << endl;
    Stack<int> myStack;
    myStack.push(10);
    myStack.push(20);
    myStack.push(30);

    cout << "Top: " << myStack.top() << endl;
    cout << "Popping: ";
    while (!myStack.empty()) {
        cout << myStack.pop() << " ";
    }
    cout << endl;

    // Custom stack with strings
    cout << "\n--- Custom Stack<string> ---" << endl;
    Stack<string> strStack;
    strStack.push("Hello");
    strStack.push("World");
    strStack.push("C++");
    while (!strStack.empty()) {
        cout << strStack.pop() << " ";
    }
    cout << endl;

    // STL stack
    cout << "\n--- std::stack ---" << endl;
    stack<int> stl_stack;
    for (int i = 1; i <= 5; i++) stl_stack.push(i * 10);
    cout << "Size: " << stl_stack.size() << ", Top: " << stl_stack.top() << endl;

    // Application: Balanced parentheses
    cout << "\n--- Balanced Parentheses ---" << endl;
    vector<string> exprs = {
        "{[()]}",
        "((()))",
        "{[(])}",
        "(()",
        "int main() { if (x[0] > 0) { return 1; } }"
    };
    for (const auto& e : exprs) {
        cout << "  \"" << e << "\" -> "
             << (check_balanced(e) ? "Balanced" : "NOT Balanced") << endl;
    }

    // Application: Postfix evaluation
    cout << "\n--- Postfix Expression Evaluation ---" << endl;
    string postfix = "3 4 + 2 * 7 /";
    cout << "  " << postfix << " = " << evaluate_postfix(postfix) << endl;
    postfix = "5 1 2 + 4 * + 3 -";
    cout << "  " << postfix << " = " << evaluate_postfix(postfix) << endl;

    // Application: Infix to Postfix
    cout << "\n--- Infix to Postfix ---" << endl;
    string infix = "3+4*2/(1-5)";
    cout << "  Infix: " << infix << endl;
    cout << "  Postfix: " << infix_to_postfix(infix) << endl;

    return 0;
}
