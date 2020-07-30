//
// Created by stacychoco on 7/30/20.
//

#include "helper.h"

string read_file(const string& path) {
// this function reads contents of a file into a string

    string str;

    // opens file
    ifstream input;
    input.open(path);

    // reads contents of file into string
    input >> str;

    // closes file
    input.close();

    return str;
}

vector<int> parse_string(const string& str) {

    // create vector for the string to be converted into
    vector<int> vector;
    stringstream str_to_parse(str);

    // while the string-stream is not empty,
    // parse the string
    while (str_to_parse.good()) {
        string substr;
        int x = 0;

        getline(str_to_parse, substr, ',');

        stringstream convert_to_int(substr);
        convert_to_int >> x;
        vector.push_back(x);
    }

    return vector;
}