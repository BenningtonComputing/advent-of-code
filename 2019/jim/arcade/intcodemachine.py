"""
 intcodemachine.py

 The IntcodeMachine as described in 
 the 2020 edition of Advent of Code
 at https://adventofcode.com/2019 .

 Jim Mahoney | cs.bennington.college | MIT License | Aug 2020 
"""

# -- preparations

# Download puzzle input files into e.g. puzzle_input/1.txt .
def puzzle_input(daynumber):
    """ return the open file for given day """
    filename = f"puzzle_inputs/{daynumber}.txt"
    try:
        return open(filename)
    except FileNotFoundError:
        print(f"Oops - couldn't find '{filename}'")

def expand(values, index, padding=128):
    """ Modify in place and return the list values[] by appending
        zeros to ensure that values[index] is not out of bounds.
        An error is raised if index is negative.
    """
    assert index >= 0, f"Oops: negative index in expand(values, index={index})"
    if index >= len(values):
        space_needed = index - len(values) + 1
        values.extend([0] * (space_needed + padding))
    return values
expand_test = [100, 101, 102]
assert expand(expand_test, 2, padding=0) == [100, 101, 102]
assert expand(expand_test, 5, padding=0) == [100, 101, 102, 0, 0, 0]
        
# -- day 5 and refactored code --

def opcode_modes(instruction):
    """ Return (opcode, (mode_1st, mode_2nd, mode_3rd)) from an instruction """
    digits = f"{instruction:05}"  # five digits e.g. 101 => '00100'
    opcode = int(digits[-2:])
    modes = (int(digits[-3]), int(digits[-4]), int(digits[-5]))
    return (opcode, modes)
assert opcode_modes(199) == (99, (1, 0, 0)) # e.g. ABCDE=00199, return (DE (C,B,A))

ops = {1:'add', 2:'multiply', 3:'read', 4:'write', 99:'halt',
       5:'jmp-if-1', 6:'jmp-if-0', 7:'lt?', 8:'eq?', 9:'base+'}

class IntcodeMachine:
    """ The amazing advent of code 2019 machine ... with all the bells and whistles """
    def __init__(self, code, inputs=None, verbose=False):
        self.code = code[:]  # work on a copy of intcodes program
        self.ip = 0          # instruction pointer = address into code
        self.inputs = [] if inputs == None else inputs[:]
        self.in_ptr = 0      # pointer into inputs
        self.outputs = []
        self.opcode = 0      # placeholder ; set while processing instruction
        self.modes = (0,0,0) # ditto
        self.base = 0        # relative mode address base (from day 9)
        self.running = True
        self.step = 0
        self.verbose = verbose
    def error(self, message):
        self.outputs.append('ERROR: ' + message)
        self.running = False
    def get_code(self, address):
        """ return code[address] """
        # With expanding memory and address checking.
        try:
            self.code = expand(self.code, address)
            return self.code[address]
        except IndexError:
            self.error(f"get code[{address}] ERROR : out of bounds")
            return 0
    def set_code(self, address, value):
        """ Put value into code[address] """
        # With expanding memory and address checking
        try:
            self.code = expand(self.code, address)
            self.code[address] = value
        except IndexError:
            self.error(f"set code[{address}]={value} out of bounds")
    def nth_address(self, n):
        """ return n'th parameter as address, including mode variations """
        parameter = self.get_code(self.ip + n)
        mode = self.modes[n - 1]
        if mode == 0:         # address mode
            return parameter
        elif mode == 2:       # relative mode; day 9
            return parameter + self.base
        else:
            # Note that immediate mode (i.e. 1) is illegal here,
            # since an "immediate" number is a value not an address.
            self.error(f"set_nth_value illegal mode={mode}")
            return None
    def nth_value(self, n): 
        """ return n'th parameter's value """
        #assert n in (1, 2)  # Only used for 1st or 2nd param ... I think.
        parameter = self.get_code(self.ip + n)
        mode = self.modes[n - 1]
        if mode == 1:                       # immediate mode
            return parameter                
        elif mode == 0:                     # address mode
            return self.get_code(parameter)
        elif mode == 2:                     #  relative mode; day 9
            return self.get_code(parameter + self.base)
        else:
            self.error(f"nth_value illegal mode={mode}")
            return 0
    def set_opcode_modes(self):
        """ Set current opcode and modes from code at ip. """
        instruction = self.get_code(self.ip)
        (self.opcode, self.modes) = opcode_modes(instruction)
    def run(self, new_inputs=None):
        """ Run the machine, with an optional list of new inputs. Return new outputs. """
        self.running = True
        len_old_outputs = len(self.outputs)
        if new_inputs:
            self.inputs.extend(new_inputs)
        while self.running:
            IM_step(self)
        return self.outputs[len_old_outputs:]
    def is_halted(self):
        """ True if the last instruction seen was halt."""
        # Refactored for machine control in Day 11.
        # The machine can now be in a running=False is_halted=False 
        # paused situation if it tries to read the next input but doesn't find it.
        return ops[self.opcode] == 'halt'
    def next_input(self, new_input):
        """ Send another input into the machine. """
        self.inputs.append(new_input)
    def last_output(self):
        """ Return last output produced by the machine. """
        return self.outputs[-1]
    def state(self):
        """ return string representation of current machine state """
        # including next instruction and parameters 
        ip = self.ip
        modes = f"{self.modes[0]},{self.modes[1]},{self.modes[2]}"
        params = f"{self.get_code(ip+1)},{self.get_code(ip+2)},{self.get_code(ip+3)}"
        return (f"{self.step}: {ops[self.opcode]}" 
                f" ip={self.ip} base={self.base}"
                f" modes={modes} params={params}"
                f" in={self.inputs} out={self.outputs}" )

def IM_add(self):
    """ IntcodeMachine addition operation. """
    values = (self.nth_value(1), self.nth_value(2))
    address = self.nth_address(3)   # parameter 3 is address (mode dependent)
    self.set_code(address, values[0] + values[1])
    self.ip += 4  # skip past (instruction, param_1, param_2, param_3)
    
def IM_multiply(self):
    """ IntcodeMachine multiplication operation. """
    values = (self.nth_value(1), self.nth_value(2))
    address = self.nth_address(3)   # parameter 3 is address (mode dependent)
    self.set_code(address, values[0] * values[1])
    self.ip += 4  # skip past (instruction, param_1, param_2, param_3)
    
def IM_read(self):
    """ IntcodeMachine read from input; put at address in parameter 1 """
    address = self.nth_address(1)   # parameter 1, mode dependent
    try:
        input_value = self.inputs[self.in_ptr]
    except IndexError:
        # Refactored for Day 11 - a third way to run the machine.
        # (See also Day 7 Part 2, which runs 1 input to get 1 output.)
        # Tried to read but no input available.
        # So stop here, back up the step counter, leave machine state the same,
        # ready to try this instruction after more input is added.
        self.step -= 1
        self.running = False
        return
    self.set_code(address, input_value)
    self.in_ptr += 1    # increment input pointer
    self.ip += 2        # skip past (instruction, param_1)
    
def IM_write(self):
    """ IntcodeMachine append to outputs[] the value given by parameter 1 """
    value = self.nth_value(1)   # value of parameter 1
    self.outputs.append(value)  # write to output
    self.ip += 2                # skip past (instruction, param_1)
    
def IM_halt(self):
    self.running = False

# Create the IntcodeMachine operator jump table if it isn't already defined.
# (The try/except here avoids stomping on a later, fancier version IM_ops 
# if this cell is evaluated out of order.)
try:
    IM_ops          # Defined already?
except NameError:
    IM_ops = {}     # If not, initialize it.
    
# IntcodeMachine opcodes ... but see also Day 5 Part 2, Day 7, and Day 9.
IM_ops[1] = IM_add
IM_ops[2] = IM_multiply
IM_ops[3] = IM_read
IM_ops[4] = IM_write
IM_ops[99] = IM_halt

def IM_step(self):
    """ Run one step on the IntcodeMachine ."""
    self.set_opcode_modes()
    operation = IM_ops[self.opcode]
    if self.verbose:
        print(self.state())
    operation(self)
    self.step += 1

# First example: an intcode program that copies input[0] to output.
assert IntcodeMachine([3,0,4,0,99], [1234, 5678]).run() == [1234]

# A second example given in the problem statement.
im_example_2 = IntcodeMachine([1002,4,3,4,33], [])
im_example_2.run()
assert im_example_2.outputs == []
assert im_example_2.code == [1002, 4, 3, 4, 99]

def IM_jump_if(self, test_func):
    """ Set ip to value in 2nd_param if test_func(1st_param). """
    switch = self.nth_value(1)
    address = self.nth_value(2)
    if test_func(switch):
        self.ip = address  # jump to new address
    else:
        self.ip += 3       # skip past (opcode, param_1, param_2)
    
def IM_jump_if_true(self):
    """ Set ip to value in 2nd_param if 1st_param is nonzero. """
    IM_jump_if(self, lambda s: s != 0)

def IM_jump_if_false(self):
    """ Set ip to value in 2nd_param if 1st_param is zero. """
    IM_jump_if(self, lambda s: s == 0)

def IM_1_or_0_if(self, comparison):
    """ Store 1 at 3rd_param address if comparison(1st_param, 2nd_param), 
        store 0 otherwise. """
    (switch1, switch2) = (self.nth_value(1), self.nth_value(2))
    address = self.nth_address(3)
    if comparison(switch1, switch2):
        self.set_code(address, 1)
    else:
        self.set_code(address, 0)
    self.ip += 4  # skip past opcode + 3 parameters
    
def IM_less_than(self):
    """ Store 1 at 2nd_param address if 1st_param < 2nd_param, 
        store 0 otherwise """
    IM_1_or_0_if(self, lambda a,b: a<b)

def IM_equals(self):
    """ Store 1 at 2nd_param address if 1st_param == 2nd_param, 
        store 0 otherwise """
    IM_1_or_0_if(self, lambda a,b: a==b)

# add more opcodes to the IntcodeMachine    
    
IM_ops[5] = IM_jump_if_true
IM_ops[6] = IM_jump_if_false
IM_ops[7] = IM_less_than
IM_ops[8] = IM_equals
    
# ... and more tests.

tests = ( ([3,9,8,9,10,9,4,9,99,-1,8], 8, 1),   # input 8, position
          ([3,9,8,9,10,9,4,9,99,-1,8], 9, 0),   # input not 8, position
          ([3,3,1108,-1,8,3,4,3,99],   8, 1),   # input 8, immediate
          ([3,3,1107,-1,8,3,4,3,99],   8, 0),   # input not 8, immediate
          ([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], 0, 0), # jump position
          ([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], 1, 1), # jump position
          ([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], 0, 0),   # jump immediate
          ([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], 1, 1),   # jump immediate
          ([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
            1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
            999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], 5, 999),    # below 8
           ([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
            1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
            999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], 8, 1000),   # equal to 8
           ([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
            1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
            999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], 11, 1001)   # greater than 8
        )

for (intcode, in_value, out_value) in tests:
    assert IntcodeMachine(intcode, [in_value]).run() == [out_value], (intcode, out_value)

# -- day 9 code --

def IM_adjust_base(self):
    """ Change the relative address base """
    self.base += self.nth_value(1)
    self.ip += 2       # skip past (opcode, param_1)

IM_ops[9] = IM_adjust_base

quine = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
assert IntcodeMachine(quine).run() == quine

sixteen_digits = [1102,34915192,34915192,7,4,7,99,0]
assert len(str(IntcodeMachine(sixteen_digits).run()[0])) == 16

assert IntcodeMachine([104,1125899906842624,99]).run() == [1125899906842624]

# -- day 13 --

def get_intcode(day):
    # Should have done this earlier ....
    raw = puzzle_input(day).readline().strip()
    code = parse_intcode(raw)
    #print(f"The day {day} input starts with '{raw[:19]}' and has ")
    #print(f"size {len(code)}, min {min(code)}, max {max(code)}, " 
    #      f"start {code[:4]}, end {code[-4:]}.")
    return code

