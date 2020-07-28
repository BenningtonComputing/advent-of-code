//
// Created by stacychoco on 7/27/20.
// Solution of puzzle 1 on day 1 of advent of code 2019.


#include <iostream>
#include <fstream>
#include <cmath>
using namespace std;

int main () {

    // declaring doubles since floor() can only be used for doubles
    double fuel;
    double mass;

    // opens file
    ifstream modules_file;
    modules_file.open("input.txt");

    // reads file line by line
    while (modules_file >> mass) {
        mass = floor(mass/3) - 2;
        fuel = fuel + mass;
    }

    // closes file
    modules_file.close();

    // round fuel and cast it to int
    int rounded_fuel = (int)round(fuel);
    // prints out amount of fuel needed
    cout << rounded_fuel;

    return 0;

}

