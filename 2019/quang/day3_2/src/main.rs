extern crate linked_hash_set;
use linked_hash_set::LinkedHashSet;

use std::cmp::Ordering;
//use std::collections::HashSet;
use std::env;
use std::fs;

#[derive(Debug, Eq, PartialEq, Hash, Clone, Copy)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn manhattan(&self) -> i32 {
        self.x.abs() + self.y.abs()
    }
}

impl Ord for Point {
    fn cmp(&self, other: &Self) -> Ordering {
        self.manhattan().cmp(&other.manhattan())
    }
}

impl PartialOrd for Point {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    //parsing inputs
    let mut args = env::args();
    args.next();

    //reading from file
    let raw_input = fs::read_to_string(args.next().expect("Error in filename argument"))
        .expect("Unable to read file");
    let raw_two_paths: Vec<&str> = raw_input.split("\n").take(2).collect();

    //reading each paths and storing the list of points
    let two_paths: Vec<Vec<&str>> = raw_two_paths
        .iter()
        .map(|x| x.split(",").collect())
        .collect();

    //collecting all the points
    let mut two_paths_set = Vec::new();
    for path in two_paths.iter() {
        let mut path_set = LinkedHashSet::new();
        let mut init_point: Point = Point { x: 0, y: 0 };
        for str_point in path {
            insert_points(&mut path_set, &mut init_point, &str_point);
        }
        two_paths_set.push(path_set);
    }

    //the fewest step occurs for the first intersection in the set
    let mut intersect = two_paths_set[0]
        .intersection(&two_paths_set[1])
        .map(|x| *x);

    let first_inter = intersect.next().unwrap();

    println!("{:?}", point_steps(&first_inter, &two_paths[0])
        + point_steps(&first_inter, &two_paths[1]));

    Ok(())
}

//function to generate points based on input
fn insert_points(path_set: &mut LinkedHashSet<Point>, init_point: &mut Point, turn: &str) {
    //parsing input turn
    let mut turn_bytes = turn.bytes();
    let dir = turn_bytes.next().expect("invalid dir") as char;
    let dist_str: String = turn_bytes.map(|byte| byte as char).collect();
    let dist: i32 = dist_str.parse().expect("Dist error");

    //matching what to do based on direction
    for _i in 0..dist {
        match dir {
            'R' => {
                init_point.x += 1;
            }
            'L' => {
                init_point.x -= 1;
            }
            'U' => {
                init_point.y += 1;
            }
            'D' => {
                init_point.y -= 1;
            }
            _ => panic!("invalid dir {}", dir),
        }
        path_set.insert(*init_point);
    }
}

//function to calculate steps to any point
fn point_steps(fin_point: &Point, path: &Vec<&str>) -> u32 {
    //initializing steps
    let mut step: u32 = 0;
    let mut init_point = Point{ x: 0, y: 0 };

    'outer: for turn in path.iter() {
        //parsing input turn
        let mut turn_bytes = turn.bytes();
        let dir = turn_bytes.next().expect("invalid dir") as char;
        let dist_str: String = turn_bytes.map(|byte| byte as char).collect();
        let dist: i32 = dist_str.parse().expect("Dist error");

        //matching what to do based on direction
        for _i in 0..dist {
            match dir {
                'R' => {
                    init_point.x += 1;
                }
                'L' => {
                    init_point.x -= 1;
                }
                'U' => {
                    init_point.y += 1;
                }
                'D' => {
                    init_point.y -= 1;
                }
                _ => panic!("invalid dir {}", dir),
            }
            step += 1;
            if init_point == *fin_point {
                break 'outer;
            }
        }
    }

    step
}
