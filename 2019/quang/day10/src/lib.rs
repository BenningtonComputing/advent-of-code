use std::collections::HashMap;
use std::collections::HashSet;
use std::fs;

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
    //gathering asteroids
    let mut asteroids: HashSet<Point> = HashSet::new();
    let mut x = 0;
    let mut y = 0;

    for line in input.raw_input.lines() {
        for chara in line.as_bytes().iter() {
            if *chara as char == '#' {
                asteroids.insert(Point { x, y });
            }
            x += 1;
        }
        x = 0;
        y += 1;
    }

    //tracing over asteroids to find the one with the best line of sight
    //or the one with the most number of unique position to other asteroids
    let mut max_asteroid = 0;
    let mut center_point = Point{x: 0, y: 0};

    //getting the center asteroid
    for i in asteroids.iter() {
        let mut position_map: HashMap<Position, Point> = HashMap::new();
        let mut asteroid_count = 0;

        for j in asteroids.iter() {
            if i == j {
                continue;
            }
            let position = i.position(&j);
            if !position_map.contains_key(&position) {
                position_map.insert(position, *j);
                asteroid_count += 1;
            } else {
                let old_asteroid = position_map.get(&position).unwrap().clone();
                if i.distance(&j) < i.distance(&old_asteroid) {
                    *position_map.get_mut(&position).unwrap() = j.clone();
                }
            }
        }

        if asteroid_count > max_asteroid {
            max_asteroid = asteroid_count;
            center_point = *i;
        }
    }

    //scanning and see what to blow up
    println!("{:?} {}", center_point, max_asteroid);
    let mut destroyed = 0;
    asteroids.remove(&center_point);

    //loop stop right when the 200th asteroid is destroyed
    'outer: while destroyed < 200 {
        let mut position_map: HashMap<Position, Point> = HashMap::new();

        for j in asteroids.iter() {
            let position = center_point.position(&j);
            if !position_map.contains_key(&position) {
                position_map.insert(position, *j);
            } else {
                let old_asteroid = position_map.get(&position).unwrap().clone();
                if center_point.distance(&j) < center_point.distance(&old_asteroid) {
                    *position_map.get_mut(&position).unwrap() = j.clone();
                }
            }
        }

        let mut sorted_targets = Vec::new();
        for target in position_map.values() {
            sorted_targets.push(target);
        }
        sorted_targets.sort_by(|a, b| center_point.x_angle(&a).partial_cmp(&center_point.x_angle(&b)).unwrap());

        for target in sorted_targets.iter() {
            asteroids.remove(target);
            destroyed += 1;
            println!("{}: {:?}", destroyed, target);
            if destroyed == 200 {
                break 'outer;
            }
        }
    }

    Ok(())
}

#[derive(Debug, Eq, PartialEq, Hash, Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

#[derive(Debug, Eq, PartialEq, Hash, Copy, Clone)]
struct Float {
    integral: i32,
    fraction: u32,
}

#[derive(Debug, Eq, PartialEq, Hash, Copy, Clone)]
enum Relation {
    Before,
    After,
}

#[derive(Debug, Eq, PartialEq, Hash, Copy, Clone)]
struct Position {
    slope: Option<Float>,
    relation: Relation,
}

impl Point {
    fn position(self: &Point, other: &Point) -> Position {
        let relation = match self.x < other.x {
            true => Relation::Before,
            false => match self.x == other.x {
                true => match self.y < other.y {
                    true => Relation::Before,
                    false => Relation::After,
                },
                false => Relation::After,
            },
        };

        let slope = match self.slope(other) {
            None => None,
            Some(x) => Some(Float {
                integral: x.trunc() as i32,
                fraction: (x.fract() * 10000000000.0_f32) as u32,
            })
        };

        Position { slope, relation }
    }

    fn slope(self: &Point, other: &Point) -> Option<f32> {
        if other.x - self.x == 0 {
            None
        } else {
            Some(((other.y - self.y) as f32) / ((other.x - self.x) as f32))
        }
    }

    fn distance(self: &Point, other: &Point) -> f32 {
        (((self.x - other.x) as f32).powf(2.0) + ((self.y - other.y) as f32).powf(2.0)).sqrt()
    }

    fn x_angle(self: &Point, other: &Point) -> f32 {
        match self.slope(other) {
            None => {
                if other.y > self.y {
                    90.0
                } else {
                    0.0
                }
            },
            Some(slope) => {
                //the y axis is inverse
                let y_angle = -slope.atan().to_degrees();
                if other.x > self.x {
                    90.0 - y_angle
                } else { //other.x < self.x
                    270.0 - y_angle
                }
            }
        }
    }
}
