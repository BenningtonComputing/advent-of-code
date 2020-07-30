//
// Created by stacychoco on 7/28/20.
// Day 2-1 of Advent of Code 2019.

#include "helper.h"

int main(){

    // reads contents from input file and put it into a string
    string program_str = read_file("input.txt");

    // parse string into vector v
    vector<int> v = parse_string(program_str);

    // restore 1202 program alarm
    v[1] = 12;
    v[2] = 2;

    // cast vector size into int
    int vec_size = static_cast<int>(v.size());

    // runs "program" with for-loop
    for (int i = 0; i < vec_size; i += 4) {
        if (v[i] == 99) {
            goto end;
        }

        else if (v[i] == 1) {
            v[v[i+3]] = v[v[i+1]] + v[v[i+2]];
        }

        else if (v[i] == 2) {
            v[v[i+3]] = v[v[i+1]] * v[v[i+2]];
        }

        else {
            cout << "error! \n";
            goto end;
        }
    }

    end:
    cout << "the value left at position 0 is: " << v[0];
}

