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
    let mut program_instr: Vec<i64> = raw_input
        .split(",")
        .map(|x| x.parse::<i64>().expect("Input failed"))
        .collect();
    program_instr.extend(vec![0; 10000].iter()); //initializing with 10000 more indices!

    let run = intcode_comp(0, &mut program_instr, &vec![2]);
    println!("{:?} {}", run, program_instr[run.curr_pos]);

    Ok(())
}

#[derive(Debug, Eq, PartialEq, Copy, Clone)]
enum IntcodeReturnStatus {
    Halted,
    WaitingInput,
}

#[derive(Debug, Eq, PartialEq, Copy, Clone)]
struct IntcodeStatus {
    status: IntcodeReturnStatus,
    curr_pos: usize,
    return_val: i64,
}

fn intcode_comp(
    mut curr_pos: usize,
    int_input: &mut Vec<i64>,
    cpu_input: &Vec<i64>,
) -> IntcodeStatus {
    //virtual cpu parsing logic
    let status: IntcodeReturnStatus;
    let mut curr_arg = 0;
    let mut output: i64 = -1;
    let mut relative_base = 0;
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
                output = int_input[param_get(
                    param_vec_iter.next().unwrap(),
                    int_input,
                    curr_pos,
                    relative_base,
                )];
                println!("OP4 Output: {}", output);
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
