use std::fs;

//solution for day 1 part 2.

fn main() -> Result<(), Box<dyn std::error::Error>>{
    let input = fs::read_to_string("input").expect("Unable to read file");
    let mut total_fuel: i32 = 0;
    for line in input.lines() {
       let mut fuel: i32 = line.parse()?;
       //solution of part 1 only requires minor clean-up for the part below
       loop {
           fuel = fuel / 3 - 2;
           if fuel > 0 {
               total_fuel += fuel;
           }
           else {
               break;
           }
       }
    }
    println!("{}", total_fuel);
    Ok(())
}

