//
// Created by stacychoco on 7/30/20.
// Day 3-1 of Advent of Code 2019.

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

    // calculate distance of intersections
    vector<int> distances;
    distances.reserve(intersections.size());
    for (auto i: intersections) {
        distances.push_back(i.x + i.y);
    }

    // find the smallest distance
    sort(distances.begin(), distances.end());
    cout << "The min is: " << distances[0];
}