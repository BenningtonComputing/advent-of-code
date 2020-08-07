extern crate digits_iterator;
use digits_iterator::*;

use std::collections::HashSet;
use std::collections::HashMap;
use std::{thread, time};

use std::fs;

pub struct Input {
    raw_input: String,
}

impl Input {
    pub fn new(mut args: std::env::Args) -> Result<Input, &'static str> {
        if args.len() < 2 {
            return Err("not enough arguments");
        }

        args.next();
        let filename = args.next().expect("File not found.");
        let raw_input = fs::read_to_string(filename).expect("Error opening file");

        Ok(Input { raw_input })
    }
}

pub fn run(input: Input) -> Result<(), Box<dyn std::error::Error>> {
    let mut raw_input = input.raw_input;
    raw_input.pop();
    let mut int_input: Vec<i64> = raw_input
        .split(",")
        .map(|x| x.parse::<i64>().unwrap())
        .collect();

    let mut color_map = vec![vec![0;150];40];
    let mut curr_x = 10;
    let mut curr_y = 10;
    /*let mut color_map = vec![vec![0;1000];1000];
    let mut curr_x = 500;
    let mut curr_y = 500;*/
    color_map[curr_y][curr_x] = 1;
    let mut face = 0; //starting facing angle
    let mut visited_square: HashSet<(usize, usize)> = HashSet::new();
    let mut state = IntcodeStatus {
        status: IntcodeReturnStatus::WaitingInput,
        curr_pos: 0,
        relative_base: 0,
        return_val: Vec::new(),
    };
    while state.status == IntcodeReturnStatus::WaitingInput {
        state = intcode_comp(
            state.curr_pos,
            state.relative_base,
            &mut int_input,
            &vec![color_map[curr_y][curr_x]],
            false,
        );

        //coloring color map
        color_map[curr_y][curr_x] = state.return_val[0];
        visited_square.insert((curr_x, curr_y));

        //extending color map
        if state.return_val[1] == 0 { //turn left
            face -= 90;
        } else {
            face += 90;
        }
        if face < 0 { face += 360 }; //face could only be 0, 90, 180, 270
        if face >= 360 { face -= 360 };

        match face {
            0 => {
                curr_y -= 1;
            },
            90 => {
                curr_x += 1;
            },
            180 => {
                curr_y += 1;
            },
            270 => {
                curr_x -= 1;
            },
            _ => panic!("Invalid angle: {}", face),
        }

        println!("{:?} {}", state, face);
        for i in 0..color_map.len() {
            for j in 0..color_map[0].len() {
                if (i == curr_y) & (j == curr_x) {
                    print!("*");
                } else if color_map[i as usize][j as usize] == 0 {
                    print!("_");
                } else {
                    print!("0");
                }
            }
            println!();
        }
        println!();

        //println!("{}", visited_square.len());
        thread::sleep(time::Duration::from_millis(10));
    }

    println!("{}", visited_square.len());
    Ok(())
}

fn intcode_comp(
    mut curr_pos: usize,
    mut relative_base: i64,
    int_input: &mut Vec<i64>,
    cpu_input: &Vec<i64>,
    debug: bool,
) -> IntcodeStatus {
    //big memory init
    if int_input.len() < 10000 { int_input.extend(vec![0;10000].iter()) };
    //virtual cpu parsing logic
    let status: IntcodeReturnStatus;
    let mut curr_arg = 0;
    let mut output: Vec<i64> = Vec::new();
    if debug {
        println!("Input: {:?}", cpu_input);
    }
    loop {
        if curr_pos > int_input.len() - 1 {
            panic!("vector index overflow at {}", curr_pos);
        }

        //parsing opcode
        let instruction = int_input[curr_pos];
        let opcode = instruction % 100;
        //killing opcode early if 99
        if opcode == 99 {
            status = IntcodeReturnStatus::Halted;
            break;
        };

        //parsing param and storing appropriate param val
        let param_mode = (instruction - opcode) / 100;
        let mut param_vec: Vec<u8> = param_mode.digits().rev().collect();
        while param_vec.len() < 3 {
            param_vec.push(0);
        }
        let mut param_vec_iter = param_vec.iter();

        //debugger
        if debug {
            println!("Curr_pos: {}", curr_pos);
            println!("Opcode: {}", opcode);
            println!("Param: {:?}", param_vec);
            println!("Relative Base: {}", relative_base);
            println!("Next: {} {} {}", int_input[curr_pos + 1], int_input[curr_pos + 2], int_input[curr_pos + 3]);
            //thread::sleep(time::Duration::from_millis(10000));
        }

        match opcode {
            1 | 2 => {
                let mut newnum = match opcode {
                    1 => 0,
                    2 => 1,
                    _ => panic!("how did you even get here"),
                };
                for _i in 0..2 {
                    curr_pos += 1;
                    let param = param_vec_iter.next().unwrap();
                    if opcode == 1 {
                        newnum += int_input[param_get(param, int_input, curr_pos, relative_base)];
                    } else {
                        newnum *= int_input[param_get(param, int_input, curr_pos, relative_base)];
                    }
                }
                curr_pos += 1;
                let mut_index = param_get(
                    param_vec_iter.next().unwrap(),
                    int_input,
                    curr_pos,
                    relative_base,
                );
                int_input[mut_index] = newnum;
                curr_pos += 1;
            }
            3 => {
                if curr_arg >= cpu_input.len() {
                    status = IntcodeReturnStatus::WaitingInput;
                    break;
                }
                curr_pos += 1;
                let mut_index = param_get(
                    param_vec_iter.next().unwrap(),
                    int_input,
                    curr_pos,
                    relative_base,
                );
                int_input[mut_index] = cpu_input[curr_arg];
                curr_arg += 1;
                curr_pos += 1;
            }
            4 => {
                curr_pos += 1;
                output.push(
                    int_input[param_get(
                        param_vec_iter.next().unwrap(),
                        int_input,
                        curr_pos,
                        relative_base,
                    )],
                );
                curr_pos += 1;
            }
            5 | 6 => {
                curr_pos += 1;
                let check_val = int_input[param_get(
                    param_vec_iter.next().unwrap(),
                    int_input,
                    curr_pos,
                    relative_base,
                )];
                if ((check_val != 0) & (opcode == 5)) | ((check_val == 0) & (opcode == 6)) {
                    curr_pos = int_input[param_get(
                        param_vec_iter.next().unwrap(),
                        int_input,
                        curr_pos + 1,
                        relative_base,
                    )] as usize;
                } else {
                    curr_pos += 2;
                }
            }
            7 | 8 => {
                let mut comp_vec = Vec::new();
                for _i in 0..2 {
                    curr_pos += 1;
                    let param = param_vec_iter.next().unwrap();
                    comp_vec.push(int_input[param_get(param, int_input, curr_pos, relative_base)]);
                }
                curr_pos += 1;
                let mut_index = param_get(
                    param_vec_iter.next().unwrap(),
                    int_input,
                    curr_pos,
                    relative_base,
                );
                if ((comp_vec[0] < comp_vec[1]) & (opcode == 7))
                    | ((comp_vec[0] == comp_vec[1]) & (opcode == 8))
                {
                    int_input[mut_index] = 1;
                } else {
                    int_input[mut_index] = 0;
                }
                curr_pos += 1;
            }
            9 => {
                curr_pos += 1;
                relative_base += int_input[param_get(
                    param_vec_iter.next().unwrap(),
                    int_input,
                    curr_pos,
                    relative_base,
                )];
                curr_pos += 1;
            }
            _ => panic!("invalid input {}", int_input[curr_pos]),
        };
    }

    IntcodeStatus {
        status,
        curr_pos,
        relative_base,
        return_val: output,
    }
}

//take in param return position in memory
fn param_get<'b>(param: &u8, int_input: &Vec<i64>, curr_pos: usize, relative_base: i64) -> usize {
    match param {
        0 => int_input[curr_pos] as usize,
        1 => curr_pos,
        2 => (int_input[curr_pos] + relative_base) as usize,
        _ => panic!("Invalid param mode"),
    }
}

#[derive(Debug, Eq, PartialEq)]
enum IntcodeReturnStatus {
    Halted,
    WaitingInput,
}

#[derive(Debug, Eq, PartialEq)]
struct IntcodeStatus {
    status: IntcodeReturnStatus,
    curr_pos: usize,
    relative_base: i64,
    return_val: Vec<i64>,
}
