//
// Created by stacychoco on 7/27/20.
// This is the solution of day 1, part 2 of advent of code 2019.
// Part 2 is basically adding to the code of part 1, so I didn't make a separate file here.


#include <iostream>
#include <fstream>
#include <cmath>

int main () {

    // declaring doubles since floor() can only be used for doubles
    double fuel = 0;
    double mass;

    // opens file
    std::ifstream modules_file;
    modules_file.open("input.txt");

    // reads file line by line


    // boolean expression in while-loop is true if the stream
    // is ready for more operations and false if the end
    // of the file has been reached
    while (modules_file >> mass) {
        while (mass > 0) {
            // floor() function rounds down a number
            mass = floor(mass/3) - 2;

            if (mass > 0) {
                fuel = fuel + mass;
            }
        }
    }

    // closes file
    modules_file.close();

    // round fuel and cast it to int
    int rounded_fuel = (int)round(fuel);
    // prints out amount of fuel needed
    std::cout << rounded_fuel;

    return 0;

}

