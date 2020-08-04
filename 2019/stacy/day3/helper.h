//
// Created by stacychoco on 7/31/20.
//

#ifndef STACY_HELPER_H
#define STACY_HELPER_H

#endif //STACY_HELPER_H

#include <bits/stdc++.h>
using namespace std;

struct point {
    int x;
    int y;
};

bool operator== (const point &p1, const point &p2);
bool operator!= (const point &p1, const point &p2);
bool operator> (const point &p1, const point &p2);
bool operator< (const point &p1, const point &p2);

bool compare (const point &p1, const point &p2);

void read_file(const string& path, string &wire1, string &wire2);
vector<point> draw_path(const string& wire);
vector<int> calculate_steps(const string& wire, vector<point> &intersections);