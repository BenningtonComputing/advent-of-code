use std::env;
use std::process;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let input = day13::Input::new(env::args()).unwrap_or_else(|err| {
        eprintln!("Problem parsing args: {}", err);
        process::exit(1);
    });

    day13::run(input)
}
