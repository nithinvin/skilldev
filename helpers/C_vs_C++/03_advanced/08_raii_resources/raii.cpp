/*
 * RAII and Resource Management in C++
 * Demonstrates: RAII principle, smart pointers, scope guards, move semantics
 */
#include <iostream>
#include <fstream>
#include <memory>
#include <string>
#include <vector>
#include <functional>
#include <mutex>
using namespace std;

// ===== RAII Class — Resources tied to object lifetime =====
class Context {
private:
    string name;
    ofstream log_file;
    unique_ptr<int[]> buffer;
    int buffer_size;

public:
    // Constructor acquires all resources
    Context(const string& name, const string& log_path, int buf_size)
        : name(name), log_file(log_path), buffer(make_unique<int[]>(buf_size)),
          buffer_size(buf_size) {
        if (!log_file) throw runtime_error("Cannot open log: " + log_path);
        log_file << "Context '" << name << "' created successfully" << endl;
        cout << "Context '" << name << "' created" << endl;
    }

    // Destructor releases all resources — AUTOMATICALLY
    ~Context() {
        log_file << "Context '" << name << "' destroying" << endl;
        cout << "Context '" << name << "' destroyed (all resources freed)" << endl;
        // log_file closed automatically (ofstream destructor)
        // buffer freed automatically (unique_ptr destructor)
        // name freed automatically (string destructor)
    }

    // Disable copy, enable move
    Context(const Context&) = delete;
    Context& operator=(const Context&) = delete;
    Context(Context&&) = default;
    Context& operator=(Context&&) = default;

    void use() {
        log_file << "Using context '" << name << "'" << endl;
        for (int i = 0; i < buffer_size; i++) buffer[i] = i * i;
        cout << "Context '" << name << "' used: buffer[0..4] = "
             << buffer[0] << ", " << buffer[1] << ", " << buffer[2]
             << ", " << buffer[3] << ", " << buffer[4] << endl;
    }
};

// ===== Scope Guard — Execute cleanup on scope exit =====
class ScopeGuard {
    function<void()> cleanup;
    bool active;
public:
    ScopeGuard(function<void()> f) : cleanup(move(f)), active(true) {}
    ~ScopeGuard() { if (active) cleanup(); }
    void dismiss() { active = false; }  // Cancel cleanup

    ScopeGuard(const ScopeGuard&) = delete;
    ScopeGuard& operator=(const ScopeGuard&) = delete;
};

// ===== Lock Guard (like std::lock_guard) =====
class SimpleMutex {
    bool locked = false;
public:
    void lock() { locked = true; cout << "  [Mutex locked]" << endl; }
    void unlock() { locked = false; cout << "  [Mutex unlocked]" << endl; }
};

class LockGuard {
    SimpleMutex& mtx;
public:
    LockGuard(SimpleMutex& m) : mtx(m) { mtx.lock(); }
    ~LockGuard() { mtx.unlock(); }

    LockGuard(const LockGuard&) = delete;
    LockGuard& operator=(const LockGuard&) = delete;
};

// ===== File processor using RAII =====
void process_files(const string& input_path, const string& output_path) {
    ifstream input(input_path);
    if (!input) throw runtime_error("Cannot open: " + input_path);

    ofstream output(output_path);
    if (!output) throw runtime_error("Cannot open: " + output_path);

    string line;
    while (getline(input, line)) {
        // Transform to uppercase
        for (auto& ch : line) ch = toupper(ch);
        output << line << "\n";
    }
    // Both files closed automatically at scope exit
    cout << "Files processed successfully" << endl;
}

// ===== Move Semantics — Transfer ownership efficiently =====
class BigData {
    unique_ptr<int[]> data;
    size_t size;
public:
    BigData(size_t n) : data(make_unique<int[]>(n)), size(n) {
        cout << "  BigData(" << n << ") constructed" << endl;
    }

    // Move constructor — transfers ownership, no copy
    BigData(BigData&& other) noexcept
        : data(move(other.data)), size(other.size) {
        other.size = 0;
        cout << "  BigData moved (zero-cost)" << endl;
    }

    ~BigData() {
        cout << "  BigData(" << size << ") destroyed" << endl;
    }

    size_t getSize() const { return size; }
};

BigData create_big_data() {
    BigData bd(1000000);
    return bd;  // Move semantics — no copy!
}

int main() {
    cout << "=== RAII and Resource Management in C++ ===" << endl;

    // RAII Context
    cout << "\n--- RAII Context ---" << endl;
    {
        Context ctx("TestContext", "/tmp/test_cpp_raii.log", 10);
        ctx.use();
        // Even if exception thrown here, ctx is cleaned up
    }
    cout << "(Scope ended — everything auto-cleaned)" << endl;

    // Exception safety with RAII
    cout << "\n--- Exception Safety ---" << endl;
    try {
        Context ctx("FailContext", "/tmp/test_cpp_raii2.log", 5);
        ctx.use();
        throw runtime_error("Something went wrong!");
        // ctx destructor STILL called!
    } catch (const exception& e) {
        cout << "Caught: " << e.what() << endl;
        cout << "(Resources were still freed!)" << endl;
    }

    // Scope Guard
    cout << "\n--- Scope Guard ---" << endl;
    {
        auto temp_file = "/tmp/scope_guard_test.txt";
        ofstream(temp_file) << "temporary data";
        ScopeGuard guard([temp_file]() {
            remove(temp_file);
            cout << "  Temp file cleaned up by scope guard" << endl;
        });
        // Use the file...
        cout << "  Using temp file..." << endl;
        // guard.dismiss(); // Would prevent cleanup
    }

    // Lock Guard
    cout << "\n--- Lock Guard (RAII for mutexes) ---" << endl;
    SimpleMutex mtx;
    {
        LockGuard lock(mtx);
        cout << "  Critical section..." << endl;
        // Mutex automatically unlocked at scope exit
    }

    // File processing
    cout << "\n--- File Processing (RAII) ---" << endl;
    {
        ofstream("/tmp/input_cpp.txt") << "hello world\nfrom c++ program\n";
    }
    try {
        process_files("/tmp/input_cpp.txt", "/tmp/output_cpp.txt");
        ifstream result("/tmp/output_cpp.txt");
        string line;
        cout << "Output:" << endl;
        while (getline(result, line)) cout << "  " << line << endl;
    } catch (const exception& e) {
        cout << "Error: " << e.what() << endl;
    }

    // Move semantics
    cout << "\n--- Move Semantics ---" << endl;
    BigData bd = create_big_data();  // No copy! Moved.
    cout << "  Got BigData with size=" << bd.getSize() << endl;

    // Smart pointer as RAII
    cout << "\n--- Smart Pointers as RAII ---" << endl;
    {
        auto resource = make_unique<string>("Important data");
        cout << "  Resource: " << *resource << endl;
        // Automatically freed
    }
    {
        auto shared = make_shared<string>("Shared resource");
        auto copy = shared;
        cout << "  Shared (ref_count=" << shared.use_count() << "): " << *shared << endl;
    }
    cout << "  All smart pointers freed" << endl;

    // Cleanup temp files
    remove("/tmp/test_cpp_raii.log");
    remove("/tmp/test_cpp_raii2.log");
    remove("/tmp/input_cpp.txt");
    remove("/tmp/output_cpp.txt");

    return 0;
}
