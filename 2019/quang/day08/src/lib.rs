use std::fs;

pub struct Input {
    raw_input: String
}

impl Input {
    pub fn new(mut args: std::env::Args) -> Result<Input, &'static str> {
        if args.len() < 2 {
            return Err("not enough arguments");
        }

        args.next();
        let filename = args.next().expect("File not found.");
        let raw_input = fs::read_to_string(filename).expect("Error opening file");

        Ok(Input {raw_input})
    }
}

pub fn run(input: Input) -> Result<(), Box<dyn std::error::Error>> {
    //let mut layers_count: Vec<HashMap<u8, u32>> = Vec::new();
    let w = 25;
    let h = 6;
    let mut raw_input = input.raw_input;
    raw_input.pop();
    let full_image:Vec<char> = raw_input
        .as_bytes().iter()
        .map(|x| *x as char)
        .collect();
    let mut final_image:Vec<char> = vec!['2'; w*h];
    for pixel in 0..w*h {
        let mut pixel_layers:Vec<char> = Vec::new();
        let mut i = pixel;
        loop {
            pixel_layers.push(full_image[i]);
            i += w*h;
            if i >= full_image.len() {
                break;
            }
        }

        for pixel_layer in pixel_layers.iter() {
            if *pixel_layer != '2' {
                final_image[pixel] = pixel_layer.clone();
                break;
            }
        }
    }

    //final image pretty printing
    for j in 0..h {
        for i in 0..w {
            let index = i + j * w;
            if final_image[index] == '0' {
                print!(" ");
            } else {
                print!("▯");
            }

        }
        println!("");
    }

    Ok(())
}
