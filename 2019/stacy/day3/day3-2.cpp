//
// Created by stacychoco on 8/1/20.
// Day 3-2 of Advent of Code 2019.

#include "helper.h"

int main() {
    string wire1, wire2;

    // read contents of input file
    read_file("input.txt", wire1, wire2);

    // put all points in the paths into two sets
    vector<point> path1 = draw_path(wire1);
    vector<point> path2 = draw_path(wire2);

    // find intersections of two sets
    vector<point> intersections;
    set_intersection(path1.begin(), path1.end(),
                     path2.begin(), path2.end(),
                     back_inserter(intersections), compare);

    vector<int> steps_vector1 = calculate_steps(wire1, intersections);
    vector<int> steps_vector2 = calculate_steps(wire2, intersections);

    int total_steps;
    vector<int> total_steps_vector;
    for (int i = 0; i < steps_vector1.size(); i++) {
        total_steps = steps_vector1[i] + steps_vector2[i];
        total_steps_vector.push_back(total_steps);
    }
    sort(total_steps_vector.begin(), total_steps_vector.end());

    cout << "The minimum number of steps is: " << total_steps_vector[0];
}