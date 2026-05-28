/*
 * Error Handling in C++
 * Demonstrates: exceptions, custom exception classes, RAII + exceptions,
 *               std::optional, std::expected (C++23 preview)
 */
#include <iostream>
#include <stdexcept>
#include <string>
#include <fstream>
#include <vector>
#include <optional>
#include <memory>
#include <variant>
using namespace std;

// ===== Custom Exception Hierarchy =====
class AppError : public runtime_error {
public:
    AppError(const string& msg) : runtime_error(msg) {}
};

class FileError : public AppError {
    string filename;
public:
    FileError(const string& file, const string& msg)
        : AppError("File '" + file + "': " + msg), filename(file) {}
    const string& getFilename() const { return filename; }
};

class ValidationError : public AppError {
public:
    ValidationError(const string& msg) : AppError("Validation: " + msg) {}
};

// ===== Basic Exceptions =====
double safe_divide(double a, double b) {
    if (b == 0.0) throw invalid_argument("Division by zero!");
    return a / b;
}

// ===== RAII + Exception Safety =====
class DatabaseConnection {
    string name;
public:
    DatabaseConnection(const string& n) : name(n) {
        cout << "  [DB '" << name << "' connected]" << endl;
    }
    ~DatabaseConnection() {
        cout << "  [DB '" << name << "' disconnected]" << endl;
    }
    void query(const string& sql) {
        if (sql.empty()) throw AppError("Empty query!");
        cout << "  Executing: " << sql << endl;
    }
};

void process_data(bool should_fail) {
    // Resources acquired via RAII
    DatabaseConnection db("main_db");
    auto buffer = make_unique<int[]>(1000);

    db.query("SELECT * FROM users");

    if (should_fail) {
        throw AppError("Processing failed!");
        // db and buffer are STILL cleaned up! (RAII)
    }

    db.query("UPDATE users SET active=1");
    cout << "  Processing completed successfully" << endl;
}

// ===== std::optional (C++17) — for "might not have a value" =====
optional<int> find_index(const vector<int>& v, int target) {
    for (size_t i = 0; i < v.size(); i++) {
        if (v[i] == target) return i;  // Has value
    }
    return nullopt;  // No value (not found)
}

optional<string> read_file(const string& filename) {
    ifstream file(filename);
    if (!file) return nullopt;

    string content((istreambuf_iterator<char>(file)),
                   istreambuf_iterator<char>());
    return content;
}

// ===== Result type using variant (like Rust's Result) =====
template <typename T>
using Result = variant<T, string>;  // Either value or error message

Result<int> parse_int(const string& s) {
    try {
        size_t pos;
        int val = stoi(s, &pos);
        if (pos != s.size()) return string("Trailing characters");
        return val;
    } catch (...) {
        return string("Not a valid integer: '" + s + "'");
    }
}

int main() {
    cout << "=== Error Handling in C++ ===" << endl;

    // Basic try/catch
    cout << "\n--- Basic Exceptions ---" << endl;
    try {
        cout << "10 / 3 = " << safe_divide(10, 3) << endl;
        cout << "10 / 0 = " << safe_divide(10, 0) << endl;  // throws
    } catch (const invalid_argument& e) {
        cout << "Caught: " << e.what() << endl;
    }

    // Multiple catch blocks
    cout << "\n--- Exception Hierarchy ---" << endl;
    auto try_operation = [](int code) {
        try {
            if (code == 1) throw FileError("data.csv", "not found");
            if (code == 2) throw ValidationError("age must be positive");
            if (code == 3) throw runtime_error("unexpected error");
            cout << "  Operation " << code << " succeeded" << endl;
        } catch (const FileError& e) {
            cout << "  File error: " << e.what() << endl;
        } catch (const ValidationError& e) {
            cout << "  Validation: " << e.what() << endl;
        } catch (const exception& e) {
            cout << "  General error: " << e.what() << endl;
        }
    };

    try_operation(0);
    try_operation(1);
    try_operation(2);
    try_operation(3);

    // RAII + Exception Safety
    cout << "\n--- RAII + Exception Safety ---" << endl;
    try {
        process_data(true);  // Will throw, but resources still cleaned up
    } catch (const AppError& e) {
        cout << "  Caught: " << e.what() << endl;
    }
    cout << "  (Notice: DB was disconnected despite exception!)" << endl;

    // std::optional
    cout << "\n--- std::optional ---" << endl;
    vector<int> nums = {10, 20, 30, 40, 50};

    if (auto idx = find_index(nums, 30); idx.has_value()) {
        cout << "Found 30 at index " << *idx << endl;
    }

    if (auto idx = find_index(nums, 99); !idx) {
        cout << "99 not found (optional is empty)" << endl;
    }

    // optional with value_or
    auto result = find_index(nums, 100);
    cout << "Index of 100: " << result.value_or(-1) << endl;

    // Result type (variant-based)
    cout << "\n--- Result Type (variant) ---" << endl;
    auto results = {parse_int("42"), parse_int("hello"), parse_int("123abc")};
    for (const auto& r : results) {
        if (holds_alternative<int>(r)) {
            cout << "  Parsed: " << get<int>(r) << endl;
        } else {
            cout << "  Error: " << get<string>(r) << endl;
        }
    }

    // noexcept — promise not to throw
    cout << "\n--- noexcept ---" << endl;
    auto safe_func = []() noexcept { return 42; };
    cout << "noexcept function: " << safe_func() << endl;
    cout << "is noexcept: " << boolalpha << noexcept(safe_func()) << endl;

    return 0;
}
