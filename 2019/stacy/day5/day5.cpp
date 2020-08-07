//
// Created by stacychoco on 8/6/20.
// Day 5-1 of Advent of Code 2019.

#include "helper.h"

int main(){

    // reads contents from input file and put it into a string
    string program_str = read_file("input.txt");

    // parse string into vector v
    vector<int> v = parse_string(program_str);

    // runs "program" with while-loop
    int i = 0;
    int opcode_arr[4];
    while (i < v.size()) {
        string opcode_str = to_string(v[i]);

        // parse opcode string and put it into opcode array
        parse_opcode(opcode_arr, opcode_str);

        // function to read each opcode with parameter modes taken into account
        int opcode = read_opcode(i, opcode_arr, v);

        // end loop if opcode = 99
        if (opcode == 99) {
            goto end;
        }
    }

    end:
    return 0;
}
