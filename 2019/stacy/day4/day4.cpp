//
// Created by stacychoco on 8/4/20.
// Day 4 of Advent of Code.

#include <bits/stdc++.h>
using namespace std;

int main() {

    bool same_adjacent_digits = false;
    bool never_decrease = true;
    int count = 0;

    for (int i = 264793; i <= 803935; i++) {
        string password = to_string(i);
        int size = static_cast<int>(password.size());
        for (int a = 0; a < size - 1; a++) {
            if (password[a] == password[a+1]) {
                if (password[a] != password[a-1] && password[a] != password[a+2]) {
                    same_adjacent_digits = true;
                }
            }
            if (password[a] > password[a+1]) {
                never_decrease = false;
            }
        }
        if (same_adjacent_digits && never_decrease) {
            count++;
        }
        same_adjacent_digits = false;
        never_decrease = true;
    }

    cout << "The number of passwords that meet these criteria are: " << count;
}