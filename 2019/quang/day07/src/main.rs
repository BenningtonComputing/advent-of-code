extern crate digits_iterator;
extern crate permutohedron;
use digits_iterator::*;
use permutohedron::Heap;
use std::env;
use std::fs;
use std::collections::VecDeque;

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

    //parsing virtual cpu input
    //let amp_input: Vec<i64> = args
    //    .map(|x| x.parse::<i64>().unwrap())
    //    .collect();

    let mut amp_input = vec![9,7,8,5,6];
    let permu_heap = Heap::new(&mut amp_input);
    let mut max_input = 0;
    for data in permu_heap {
        let mut last_input = 0;

        let mut machine_queue: VecDeque<IntcodeStatus> = VecDeque::new();

        //initial data for amplifiers
        for amp in data.iter() {
            let intcode_status = intcode_comp(0 as usize, &mut program_instr, &vec![*amp, last_input]);
            if intcode_status.status == IntcodeReturnStatus::WaitingInput {
                machine_queue.push_back(intcode_status);
            }
            last_input = intcode_status.return_val;
        }

        //feeding inputs
        loop {
            match machine_queue.pop_front() {
                Some(machine_status) => {
                    let intcode_status = intcode_comp(machine_status.curr_pos, &mut program_instr, &vec![last_input]);
                    if intcode_status.status == IntcodeReturnStatus::WaitingInput {
                        machine_queue.push_back(intcode_status);
                    }
                    last_input = intcode_status.return_val;
                },
                None => break
            }
        }

        if last_input > max_input {
            max_input = last_input
        }
    }

    println!("{}", max_input);

    Ok(())
}

#[derive(Debug,Eq,PartialEq,Copy,Clone)]
enum IntcodeReturnStatus {
    Halted,
    WaitingInput
}

#[derive(Debug,Eq,PartialEq,Copy,Clone)]
struct IntcodeStatus {
    status: IntcodeReturnStatus,
    curr_pos: usize,
    return_val: i64,
}

fn intcode_comp(curr: usize, int_input: &mut Vec<i64>, cpu_input: &Vec<i64>) -> IntcodeStatus {
    //virtual cpu parsing logic
    let status: IntcodeReturnStatus;
    let mut curr_pos = curr;
    let mut curr_arg = 0;
    let mut output:i64 = -1;
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
            1|2 => {
                let mut newnum = 0;
                if opcode == 1{
                    for i in param_vec_iter.take(2) {
                        curr_pos += 1;
                        newnum += match i {
                            0 => int_input[int_input[curr_pos] as usize],
                            1 => int_input[curr_pos],
                            _ => panic!("Invalid param mode"),
                        }
                    }
                } else {
                    newnum += 1;
                    for i in param_vec_iter.take(2) {
                        curr_pos += 1;
                        newnum *= match i {
                            0 => int_input[int_input[curr_pos] as usize],
                            1 => int_input[curr_pos],
                            _ => panic!("Invalid param mode"),
                        }
                    }
                }
                curr_pos += 1;
                let mod_index = int_input[curr_pos] as usize;
                int_input[mod_index] = newnum;
                curr_pos += 1;
            }
            3 => {
                if curr_arg >= cpu_input.len() {
                    status = IntcodeReturnStatus::WaitingInput;
                    break;
                }
                curr_pos += 1;
                let mod_index = int_input[curr_pos] as usize;
                int_input[mod_index] = cpu_input[curr_arg];
                curr_arg += 1;
                curr_pos += 1;
            }
            4 => {
                curr_pos += 1;
                output = int_input[int_input[curr_pos] as usize];
                curr_pos += 1;
            }
            5 | 6 => {
                curr_pos += 1;
                let check_val = match param_vec_iter.next().unwrap() {
                    0 => int_input[int_input[curr_pos] as usize],
                    1 => int_input[curr_pos],
                    _ => panic!("Invalid param mode"),
                };
                if ((check_val != 0) & (opcode == 5)) | ((check_val == 0) & (opcode == 6)) {
                    curr_pos = match param_vec_iter.next().unwrap() {
                        0 => int_input[int_input[curr_pos + 1] as usize] as usize,
                        1 => int_input[curr_pos + 1] as usize,
                        _ => panic!("Invalid param mode"),
                    };
                } else {
                    curr_pos += 2;
                }
            }
            7 | 8 => {
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
                if ((comp_vec[0] < comp_vec[1]) & (opcode == 7))
                    | ((comp_vec[0] == comp_vec[1]) & (opcode == 8))
                {
                    int_input[mod_index] = 1;
                } else {
                    int_input[mod_index] = 0;
                }
                curr_pos += 1;
            }
            _ => panic!("invalid input {}", int_input[curr_pos]),
        };
    }

    IntcodeStatus{status, curr_pos, return_val: output}
}
