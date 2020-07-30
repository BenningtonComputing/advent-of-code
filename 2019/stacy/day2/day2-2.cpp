//
// Created by stacychoco on 7/28/20.
// Day 2-2 of Advent of Code 2019.

#include "helper.h"

int main(){

    // reads contents from input file and put it into a string
    string program_str = read_file("input.txt");

    // parse string into vector v
    vector<int> v = parse_string(program_str);

    // cast vector size into int
    int vec_size = static_cast<int>(v.size());

    // makes copy of v so v can be reset later
    vector<int> v_copy = v;

    for (int x = 0; x < 100; x++) {
        for (int y = 0; y < 100; y++) {
            // tests values from 0-99
            v[1] = x;
            v[2] = y;

            // runs "program" with for-loop
            for (int i = 0; i < vec_size; i += 4) {
                if (v[i] == 99) {
                    goto end_of_test1;
                }

                else if (v[i] == 1) {
                    v[v[i+3]] = v[v[i+1]] + v[v[i+2]];
                }

                else if (v[i] == 2) {
                    v[v[i+3]] = v[v[i+1]] * v[v[i+2]];
                }

                else {
                    cout << "error! \n";
                    goto end_of_test2;
                }

            }

            end_of_test1:
            if (v[0] == 19690720) {
                cout << "the result is: " << 100 * x + y << endl;
                goto the_end;
            }

            // reset v
            end_of_test2:
            v = v_copy;

        }
    }

    the_end:
    return 0;
}

