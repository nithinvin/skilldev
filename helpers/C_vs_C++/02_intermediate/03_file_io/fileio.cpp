/*
 * File I/O in C++
 * Demonstrates: fstream, ifstream, ofstream, string streams, serialization
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <iomanip>
using namespace std;

struct Record {
    int id;
    string name;
    double score;

    // Serialize to text
    friend ostream& operator<<(ostream& os, const Record& r) {
        os << setw(5) << left << r.id
           << setw(20) << left << r.name
           << fixed << setprecision(1) << r.score;
        return os;
    }

    // Deserialize from text
    friend istream& operator>>(istream& is, Record& r) {
        is >> r.id >> r.name >> r.score;
        return is;
    }
};

int main() {
    cout << "=== File I/O in C++ ===" << endl << endl;

    // Text file writing using ofstream
    cout << "--- Writing text file ---" << endl;
    {
        ofstream file("output_cpp.txt");  // Opens file (RAII)
        if (!file) {
            cerr << "Error opening file!" << endl;
            return 1;
        }

        file << "Student Records" << endl;
        file << string(20, '=') << endl;

        vector<Record> records = {
            {1, "Alice", 95.5},
            {2, "Bob", 87.3},
            {3, "Charlie", 92.0}
        };

        file << setw(5) << left << "ID"
             << setw(20) << left << "Name"
             << "Score" << endl;

        for (const auto& r : records) {
            file << r << endl;
        }
        // File automatically closed at end of scope (RAII)
    }
    cout << "Written to output_cpp.txt" << endl;

    // Text file reading using ifstream
    cout << "\n--- Reading text file ---" << endl;
    {
        ifstream file("output_cpp.txt");
        if (!file) {
            cerr << "Error opening file!" << endl;
            return 1;
        }

        string line;
        while (getline(file, line)) {
            cout << "  " << line << endl;
        }
        // File automatically closed
    }

    // Binary file I/O
    cout << "\n--- Writing binary file ---" << endl;
    {
        ofstream file("records_cpp.bin", ios::binary);
        vector<Record> records = {
            {1, "Alice", 95.5},
            {2, "Bob", 87.3},
            {3, "Charlie", 92.0}
        };

        size_t count = records.size();
        file.write(reinterpret_cast<const char*>(&count), sizeof(count));
        for (const auto& r : records) {
            file.write(reinterpret_cast<const char*>(&r.id), sizeof(r.id));
            size_t name_len = r.name.size();
            file.write(reinterpret_cast<const char*>(&name_len), sizeof(name_len));
            file.write(r.name.c_str(), name_len);
            file.write(reinterpret_cast<const char*>(&r.score), sizeof(r.score));
        }
        cout << "Written " << count << " records to records_cpp.bin" << endl;
    }

    // Reading binary
    cout << "\n--- Reading binary file ---" << endl;
    {
        ifstream file("records_cpp.bin", ios::binary);
        size_t count;
        file.read(reinterpret_cast<char*>(&count), sizeof(count));
        cout << "Number of records: " << count << endl;

        for (size_t i = 0; i < count; i++) {
            int id;
            file.read(reinterpret_cast<char*>(&id), sizeof(id));
            size_t name_len;
            file.read(reinterpret_cast<char*>(&name_len), sizeof(name_len));
            string name(name_len, '\0');
            file.read(&name[0], name_len);
            double score;
            file.read(reinterpret_cast<char*>(&score), sizeof(score));
            cout << "  ID: " << id << ", Name: " << name << ", Score: " << score << endl;
        }
    }

    // String streams — in-memory formatting
    cout << "\n--- String Streams ---" << endl;
    ostringstream oss;
    oss << "Formatted: " << fixed << setprecision(2) << 3.14159 << " | " << 42;
    string formatted = oss.str();
    cout << formatted << endl;

    // Parsing with stringstream
    string csv_line = "4 Diana 88.7";
    istringstream iss(csv_line);
    Record r;
    iss >> r;
    cout << "Parsed: " << r << endl;

    // Cleanup
    remove("output_cpp.txt");
    remove("records_cpp.bin");

    return 0;
}
