extern crate digits_iterator;
use digits_iterator::*;
use std::env;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    //parsing input
    let mut args = env::args();
    args.next();

    //parsing input and converting to a vector
    let mut raw_input = fs::read_to_string(args.next().unwrap()).expect("Unable to read file");
    raw_input.pop(); //remove trailing newline
    let mut int_input: Vec<i32> = raw_input
        .split(",")
        .map(|x| x.parse::<i32>().expect("Input failed"))
        .collect();

    //parsing virtual cpu input
    let cpu_input = args
        .next()
        .unwrap()
        .parse::<i32>()
        .expect("cpu input parsring fail");

    //virtual cpu parsing logic
    let mut curr_pos:usize = 0;
    loop {
        println!("{:?}", int_input);

        if curr_pos > int_input.len() - 1 {
            panic!("vector index overflow at {}", curr_pos);
        }

        //parsing opcode
        let instruction = int_input[curr_pos];
        let opcode = instruction % 100;
        //killing opcode early if 99
        if opcode == 99 {
            break;
        };

        //parsing param and storing appropriate param val
        let param_mode = (instruction - opcode) / 100;
        let mut param_vec:Vec<u8> = param_mode.digits().rev().collect();
        while param_vec.len() < 3 {
            param_vec.push(0);
        }
        let mut param_vec_iter = param_vec.iter();
        println!("{:?}", param_vec);

        match opcode {
            1 => {
                let mut newnum = 0;
                for i in param_vec_iter.take(2) {
                    curr_pos += 1;
                    newnum += match i {
                        0 => int_input[int_input[curr_pos] as usize],
                        1 => int_input[curr_pos],
                        _ => panic!("Invalid param mode"),
                    }
                }
                curr_pos += 1;
                let mod_index = int_input[curr_pos] as usize;
                int_input[mod_index] = newnum;
                curr_pos += 1;
            }
            2 => {
                let mut newnum = 1;
                for i in param_vec_iter.take(2) {
                    curr_pos += 1;
                    newnum *= match i {
                        0 => int_input[int_input[curr_pos] as usize],
                        1 => int_input[curr_pos],
                        _ => panic!("Invalid param mode"),
                    }
                }
                curr_pos += 1;
                let mod_index = int_input[curr_pos] as usize;
                int_input[mod_index] = newnum;
                curr_pos += 1;
            }
            3 => {
                curr_pos += 1;
                let mod_index = int_input[curr_pos] as usize;
                int_input[mod_index] = cpu_input;
                curr_pos += 1;
            }
            4 => {
                curr_pos += 1;
                println!("OP4 output: {}", int_input[int_input[curr_pos] as usize]);
                curr_pos += 1;
            }
            5 => {
                curr_pos += 1;
                let check_val = match param_vec_iter.next().unwrap() {
                    0 => int_input[int_input[curr_pos] as usize],
                    1 => int_input[curr_pos],
                    _ => panic!("Invalid param mode"),
                };
                if check_val != 0 {
                    curr_pos = match param_vec_iter.next().unwrap() {
                        0 => int_input[int_input[curr_pos + 1] as usize] as usize,
                        1 => int_input[curr_pos + 1] as usize,
                        _ => panic!("Invalid param mode"),
                    };
                } else { curr_pos += 2; }
            }
            6 => {
                curr_pos += 1;
                let check_val = match param_vec_iter.next().unwrap() {
                    0 => int_input[int_input[curr_pos] as usize],
                    1 => int_input[curr_pos],
                    _ => panic!("Invalid param mode"),
                };
                if check_val == 0 {
                    curr_pos = match param_vec_iter.next().unwrap() {
                        0 => int_input[int_input[curr_pos + 1] as usize] as usize,
                        1 => int_input[curr_pos + 1] as usize,
                        _ => panic!("Invalid param mode"),
                    };
                } else { curr_pos += 2; }
            }
            7 => {
                let mut comp_vec = Vec::new();
                for i in param_vec_iter.take(2) {
                    curr_pos += 1;
                    comp_vec.push(match i {
                        0 => int_input[int_input[curr_pos] as usize],
                        1 => int_input[curr_pos],
                        _ => panic!("Invalid param mode"),
                    })
                }
                curr_pos += 1;
                let mod_index = int_input[curr_pos] as usize;
                if comp_vec[0] < comp_vec[1] {
                    int_input[mod_index] = 1;
                } else { int_input[mod_index] = 0; }
                curr_pos += 1;
            }
            8 => {
                let mut comp_vec = Vec::new();
                for i in param_vec_iter.take(2) {
                    curr_pos += 1;
                    comp_vec.push(match i {
                        0 => int_input[int_input[curr_pos] as usize],
                        1 => int_input[curr_pos],
                        _ => panic!("Invalid param mode"),
                    })
                }
                curr_pos += 1;
                let mod_index = int_input[curr_pos] as usize;
                if comp_vec[0] == comp_vec[1] {
                    int_input[mod_index] = 1;
                } else { int_input[mod_index] = 0; }
                curr_pos += 1;
            }
            _ => panic!("invalid input {}", int_input[curr_pos]),
        };
    }

    Ok(())
}
