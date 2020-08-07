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
    let mut int_input: Vec<u32> = raw_input
        .split(",")
        .map(|x| x.parse::<u32>().expect("Input failed"))
        .collect();

    //input initial state recovering
    //with 2nd argument == f
    if args.next() == Some("f".to_string()) {
        int_input[1] = 12;
        int_input[2] = 2;
    }

    //virtual cpu parsing logic
    let mut curr_pos = 0;
    loop {
        println!("{:?}\n", int_input);

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

    //printing desired value
    println!("{}", int_input[0]);
    Ok(())
}
