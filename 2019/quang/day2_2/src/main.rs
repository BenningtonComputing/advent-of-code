use std::env;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    //parsing input
    let mut args = env::args();
    args.next();

    //parsing input and converting to a vector
    let mut raw_input = fs::read_to_string(args.next().unwrap())
        .expect("Unable to read file");
    raw_input.pop(); //remove trailing newline
    let int_input_init: Vec<u32> = raw_input
        .split(",")
        .map(|x| x.parse::<u32>().expect("Input failed"))
        .collect();

    //loop to find correct addresses
    //virtual cpu parsing logic
    for addr1 in 0..100 {
        for addr2 in 0..100{
            let mut int_input = int_input_init.clone();
            int_input[1] = addr1;
            int_input[2] = addr2;

            let mut curr_pos = 0;
            loop {
                if curr_pos > int_input.len() - 1 {
                    panic!("vector index overflow at {}", curr_pos);
                }

                let new_num = match int_input[curr_pos] {
                    1 => int_input[int_input[curr_pos + 1] as usize]
                        + int_input[int_input[curr_pos + 2] as usize],
                    2 => int_input[int_input[curr_pos + 1] as usize]
                        * int_input[int_input[curr_pos + 2] as usize],
                    99 => break,
                    _ => panic!("invalid input {}", int_input[curr_pos]),
                };
                let mod_index = int_input[curr_pos + 3] as usize;
                int_input[mod_index] = new_num;
                curr_pos += 4;
            }

            if int_input[0] == 19690720 {
                println!("{} {}", addr1, addr2);
                break;
            }
        }
    }

    Ok(())
}
