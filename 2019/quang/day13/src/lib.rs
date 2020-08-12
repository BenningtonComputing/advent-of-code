extern crate digits_iterator;
use digits_iterator::*;

use std::fs;
use std::cmp::Ordering;

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
    //updating input to allow playing
    int_input[0] = 2;

    let mut input: Vec<i64> = Vec::new();
    let mut score = 0;
    loop {
        let output = intcode_comp(0, 0, &mut int_input, &input, false);
        let mut block_count = 0;
        let mut i = 2;
        let mut pad_pos: (i64, i64) = (0, 0);
        let mut ball_pos: (i64, i64) = (0, 0);

        let mut game_state = vec![vec![0;100];30];
        //get game state
        loop {
            //detect score
            if output.return_val[i-2] == -1 && output.return_val[i-1] == 0 {
                score = output.return_val[i];
                i += 3;
                if i >= output.return_val.len() {
                    break;
                }
                continue;
            }

            //get metadata
            match output.return_val[i] {
                2 => block_count += 1, //count block
                3 => pad_pos = (output.return_val[i-2], output.return_val[i-1]), //get paddle pos
                4 => ball_pos = (output.return_val[i-2], output.return_val[i-1]), //get ball pos
                _ => ()
            }

            //store game state
            game_state[output.return_val[i-1] as usize][output.return_val[i-2] as usize] = output.return_val[i];
            i += 3;
            if i >= output.return_val.len() {
                break;
            }
        }

        //update input
        input = match (pad_pos.0).cmp(&ball_pos.0) {
            Ordering::Less => vec![1], //pad's x < ball's x
            Ordering::Equal => vec![0],
            Ordering::Greater => vec![-1],
        };

        if block_count == 0 {
            break;
        }

        //print game state
        println!("block: {}, score: {}", block_count, score);
        for row in game_state.iter() {
            for col in row.iter() {
                match col {
                    0 => print!(" "),
                    1 => print!("#"),
                    2 => print!("+"),
                    3 => print!("="),
                    4 => print!("o"),
                    _ => ()
                }
            }
            println!();
        }
    }

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
