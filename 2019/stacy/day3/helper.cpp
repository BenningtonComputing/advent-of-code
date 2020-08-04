//
// Created by stacychoco on 7/31/20.
//

#include "helper.h"

struct point;

bool operator== (const point &p1, const point &p2) {
    return (p1.x == p2.x && p1.y == p2.y);
}

bool operator!= (const point &p1, const point &p2) {
    return !(p1 == p2);
}

bool operator> (const point &p1, const point &p2) {
    return ((p1.x + p1.y) > (p2.x + p2.y));
}

bool operator< (const point &p1, const point &p2) {
    return !(p1 > p2);
}

bool compare (const point &p1, const point &p2) {
    return p1.x*10000000000 + p1.y < p2.x*10000000000 + p2.y;
}

void read_file(const string& path, string &wire1, string &wire2) {
// this function reads contents of input file into 2 wires

    // opens file
    ifstream input;
    input.open(path);

    // reads contents of file into string
    input >> wire1;
    input >> wire2;

    // closes file
    input.close();
}

vector<point> draw_path(const string& wire) {

    vector<point> path;
    point coordinate{0, 0};
    // create string-streams for parsing
    stringstream wire_stream(wire);

    // while the string-stream is not empty,
    // parse the string
    while (wire_stream.good()) {
        string substr; // includes both direction and distance

        // the path is put into the sub-string
        getline(wire_stream, substr, ',');
        // find the direction to walk in
        char dir = substr[0];
        int dist;
        stringstream convert_to_int(substr.substr(1));
        convert_to_int >> dist;

        for (int i = 0; i < dist; i++) {
            switch (dir) {
                case 'L':
                    coordinate.x--;
                    break;
                case 'R':
                    coordinate.x++;
                    break;
                case 'U':
                    coordinate.y++;
                    break;
                case 'D':
                    coordinate.y--;
                    break;
                default:
                    break;
            }
            path.push_back(coordinate);
        }

        sort(path.begin(), path.end(), compare);
    }

    return path;
}

vector<int> calculate_steps(const string& wire, vector<point> &intersections) {

    int steps = 0;
    map<point, int> steps_map;
    point coordinate{0, 0};
    // create string-streams for parsing
    stringstream wire_stream(wire);

    // while the string-stream is not empty,
    // parse the string
    while (wire_stream.good()) {
        string substr; // includes both direction and distance

        // the path is put into the sub-string
        getline(wire_stream, substr, ',');
        // find the direction to walk in
        char dir = substr[0];
        int dist;
        stringstream convert_to_int(substr.substr(1));
        convert_to_int >> dist;

        for (int i = 0; i < dist; i++) {
            switch (dir) {
                case 'L':
                    coordinate.x--;
                    break;
                case 'R':
                    coordinate.x++;
                    break;
                case 'U':
                    coordinate.y++;
                    break;
                case 'D':
                    coordinate.y--;
                    break;
                default:
                    break;
            }
            steps++;
            // if the coordinate is found in the intersections vector
            if (find(intersections.begin(), intersections.end(), coordinate) != intersections.end()) {
                // put the number of steps into steps map
                steps_map[coordinate] = steps;
            }
        }
    }

    // extract the number of steps into a vector
    // the steps are first put into a dictionary with coordinates as keys
    // so that they are sorted by default
    vector<int> steps_vector;
    steps_vector.reserve(steps_map.size());
    for (auto &i: steps_map) {
        steps_vector.push_back(i.second);
    }

    return steps_vector;
}