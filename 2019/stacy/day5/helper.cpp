//
// Created by stacychoco on 8/6/20.
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

void parse_opcode(int (&opcode_arr)[4], string &opcode_str) {
    while (opcode_str.size() < 5) {
        opcode_str.insert(0, "0");
    }
    for (int a = 0; a < 3; a++) {
        // convert char to int
        int mode = opcode_str[a] - '0';
        opcode_arr[a] = mode;
    }
    opcode_arr[3] = stoi(opcode_str.substr(3, 2));
}

int read_opcode(int &i, int (&opcode_arr)[4], vector<int> &v) {
    int opcode = opcode_arr[3];
    if (opcode == 99 || opcode == 3) {
        goto switch_case;
    }

    for (int a = 2, b = 1; a > 0 && b < 3; a--, b++) {
        switch (opcode_arr[a]) {
            case 0:
                opcode_arr[a] = v[v[i+b]];
                break;
            case 1:
                opcode_arr[a] = v[i+b];
                break;
        }
    }

    opcode_arr[0] = v[i+3];

    switch_case:
    int para1 = opcode_arr[2];
    int para2 = opcode_arr[1];
    int para3 = opcode_arr[0];

    switch (opcode){
        case 1:
            v[para3] = para2 + para1;
            i += 4;
            break;
        case 2:
            v[para3] = para2 * para1;
            i += 4;
            break;
        case 3:
            cout << "Enter system ID: ";
            cin >> v[v[i+1]];
            i += 2;
            break;
        case 4:
            cout << para1 << endl;
            if (para1 != 0 && v[i+2] != 99) {
                cout << "error! \n";
            }
            i += 2;
            break;
        case 5:
            if (para1) {
                i = para2;
            }
            else {
                i += 3;
            }
            break;
        case 6:
            if (!para1) {
                i = para2;
            }
            else {
                i += 3;
            }
            break;
        case 7:
            if (para1 < para2) {
                v[para3] = 1;
            }
            else {
                v[para3] = 0;
            }
            i += 4;
            break;
        case 8:
            if (para1 == para2) {
                v[para3] = 1;
            }
            else {
                v[para3] = 0;
            }
            i += 4;
            break;
        default:
            break;
    }

    return opcode;
}