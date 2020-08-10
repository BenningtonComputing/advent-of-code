use std::fs;

pub struct Input {
    raw_input: String,
    step: u32,
}

impl Input {
    pub fn new(mut args: std::env::Args) -> Result<Input, &'static str> {
        if (args.len() < 2) | (args.len() > 3) {
            return Err("number arguments need to be = 2 or 3");
        }

        args.next();
        let filename = args.next().expect("File not found.");
        let raw_input = fs::read_to_string(filename).expect("Error opening file");
        let step:u32 = args.next().unwrap_or("0".to_string()).parse().unwrap();

        Ok(Input { raw_input, step })
    }
}

pub fn run(input: Input) -> Result<(), Box<dyn std::error::Error>> {
    //getting planets info
    let raw_input = input.raw_input;
    let mut init_planets: Vec<Planet> = Vec::new();
    for line in raw_input.lines() {
        init_planets.push(parse_planet(line));
    }
    let mut planets = init_planets.clone();
    let mut steps: Vec<u64> = vec![0;3];

    //looping till init
    //get the moment when the axis loops separately
    //then find the lcm of the 3 axis
    //source:
    //https://old.reddit.com/r/adventofcode/comments/e9jxh2/help_2019_day_12_part_2_what_am_i_not_seeing/
    for axis in 0..steps.len() {
        'main: loop {
            //updating velocity
            for i in 0..planets.len() {
                for j in i+1..planets.len() {
                    if planets[i].pos[axis] < planets[j].pos[axis] {
                        planets[i].vel[axis] += 1;
                        planets[j].vel[axis] -= 1;
                    } else if planets[i].pos[axis] > planets[j].pos[axis] {
                        planets[i].vel[axis] -= 1;
                        planets[j].vel[axis] += 1;
                    } else {
                        continue;
                    }
                }
            }

            //updating position
            for i in 0..planets.len() {
                for axis in 0..planets[i].pos.len() {
                    planets[i].pos[axis] += planets[i].vel[axis];
                }
            }

            steps[axis] += 1;

            for p in 0..planets.len() {
                if planets[p].pos[axis] != init_planets[p].pos[axis] {
                    continue 'main;
                }
                if planets[p].vel[axis] != init_planets[p].vel[axis] {
                    continue 'main;
                }
            }

            break;
        }
    }

    /*let mut total_energy = 0;
    for planet in planets.iter() {
        total_energy += planet.pot_energy() * planet.kin_energy();
    }
    println!("{}", total_energy);*/
    println!("{:?}", steps);
    Ok(())
}

#[derive(Debug, Clone, Eq, PartialEq)]
struct Planet {
    pos: Vec<i32>,
    vel: Vec<i32>,
}

impl Planet {
    fn pot_energy(&self) -> i32 {
        self.pos.iter().map(|x| x.abs()).sum()
    }
    fn kin_energy(&self) -> i32 {
        self.vel.iter().map(|x| x.abs()).sum()
    }
}

fn parse_planet(planet_info: &str) -> Planet {
    //planet_info of the form: <x=x, y=y, z=z>
    let info:Vec<i32> = planet_info
        .get(1..planet_info.len()-1)
        .unwrap()
        .split(", ")
        .map(|x| x.get(2..).unwrap().parse().unwrap())
        .collect();
    Planet{ pos: vec![info[0], info[1], info[2]], vel: vec![0;3] }
}
