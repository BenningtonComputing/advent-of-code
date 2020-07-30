extern crate digits_iterator;
use digits_iterator::*;
use std::env;

fn main() -> Result<(), Box<dyn std::error::Error>>{
    //parsing inputs
    let mut args = env::args();
    args.next();

    //reading from input
    let open:u32 = args
        .next()
        .expect("opening range missing")
        .parse()
        .expect("int type");
    let close:u32 = args
        .next()
        .expect("closing range missing")
        .parse()
        .expect("int type");
    let mut count = 0;
    for i in open..close+1 {
        if verify_number(i) {
            count += 1;
        }
    }
    println!("{}", count);
    Ok(())
}

fn verify_number(input: u32) -> bool {
    let mut digits = input.digits();
    let mut last_digit = digits.next().unwrap();
    let mut ascending = true;
    let mut same_digit = false;
    let mut same_digit_count = 1;
    for digit in digits {
        if digit < last_digit {
            ascending = false;
        }

        //solution for part 1 could be achieved by altering the logic here
        if digit == last_digit {
            same_digit_count += 1;
        } else {
            if !same_digit & (same_digit_count == 2) {
                same_digit = true;
            }
            same_digit_count = 1;
        }

        last_digit = digit;
    }
    if same_digit_count == 2 {
        same_digit = true;
    }
    same_digit & ascending
}
