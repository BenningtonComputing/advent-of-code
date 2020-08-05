//
// Created by stacychoco on 8/4/20.
// Day 4 of Advent of Code.

#include <bits/stdc++.h>
using namespace std;

int main() {

    bool same_adjacent_digits = false;
    bool never_decrease = false;
    int count = 0;

    for (int i = 264793; i <= 803935; i++) {
        string password = to_string(i);
        int size = static_cast<int>(password.size());
        for (int a = 0; a < size - 1; a++) {
            if (password[a] == password[a+1]) {
                same_adjacent_digits = true;
            }
            for (int b = a + 1; b < size; b++) {
                if (password[a] < password[b] || password[a] == password[b]) {
                    if (b == size - 1) {
                        if (password[b] < password[0]) {
                            never_decrease = true;
                        }
                    }
                    else {
                        never_decrease = true;
                    }
                }
                else {
                    goto loop_reset;
                }
            }
        }
        if (same_adjacent_digits && never_decrease) {
            count++;
        }
        loop_reset:
        same_adjacent_digits = false;
        never_decrease = false;
    }

    cout << "The number of passwords that meet these criteria are: " << count;
}