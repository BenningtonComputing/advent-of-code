//
// Created by stacychoco on 8/6/20.
//

#ifndef STACY_HELPER_H
#define STACY_HELPER_H

#endif //STACY_HELPER_H

#include <bits/stdc++.h>
using namespace std;

string read_file(const string& path);
vector<int> parse_string(const string& str);
int read_opcode(int &i, int (&opcode_arr)[4], vector<int> &v);
void parse_opcode(int (&opcode_arr)[4], string &opcode_str);