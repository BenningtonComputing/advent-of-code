use std::fs;
use std::cell::RefCell;
use std::rc::Rc;
use std::collections::HashMap;
use std::ops::Deref;

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
    /*
     * RefCell<Rc<RefCell<Planet>>>
     * the purpose of this hashmap is to track the name and planets
     * each planet in itself has a pointer to the planet it is orbitting
     * therefore, we need to let planets point to other planets in the same hashmap
     *
     * the first refcell is to allow borrowing of hashmap's values mutably and immutably
     * at the same time, for mutating the pointers in one value to point to another value
     *
     * the second rc is to allow a planet to have multiple pointers pointing towards it. this
     * implies a planet being orbitted by multiple other planets
     *
     * the third refcell is to allow the mutation of the data within the rc, since you cannot
     * mutate value within rc without implementing the DerefTrait first
     */
    let mut planet_list:HashMap<&str, RefCell<Rc<RefCell<Planet>>>> = HashMap::new();
    for line in input.raw_input.lines() {
        //parsing line
        let mut line_split = line.split(')');
        let front = line_split.next()
            .expect(&format!("read front fail at {}", line));
        let back = line_split.next()
            .expect(&format!("read back fail at {}", line));

        //finding planets
        {
            planet_list.entry(front)
                .or_insert(RefCell::new(Rc::new(RefCell::new(Planet{orbit: None}))));
            planet_list.entry(back)
                .or_insert(RefCell::new(Rc::new(RefCell::new(Planet{orbit: None}))));
        }

        //assigning planets
        let mut back_planet = planet_list.get(back).unwrap().borrow_mut();
        let front_planet = planet_list.get(front).unwrap().borrow();
        (*back_planet).borrow_mut().orbit = Some(Rc::clone(&front_planet));
    }

    //actually printing out the result
    let mut out = 0;
    for planet in planet_list.values() {
        out += (*planet.borrow()).borrow().orbitting();
    }
    println!("{}", out);
    Ok(())
}

#[derive(Debug)]
struct Planet {
    //orbit: Rc<RefCell<Option<Planet>>>,
    //orbit: Option<&'a Planet<'a>>,
    orbit: Option<Rc<RefCell<Planet>>>,
}

impl Planet {
    //orbitting takes a reference to self not a copy
    //therefore the self is passed by reference
    fn orbitting(&self) -> u32 {
        match self.orbit {
            Some(_) => self.orbit
                .as_ref().unwrap() //getting the value of the option as reference
                .deref() //dereferencing the smart pointer in the option
                .borrow() //borrowing the refcell content
                .orbitting() + 1, //getting the inner value
            None => 0
        }
    }
}
