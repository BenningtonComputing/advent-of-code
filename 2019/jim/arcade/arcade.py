"""
 arcade.py

 The breakout-like arcade from Advent of Code's "Day 13: Care Package"
 at https://adventofcode.com/2019/day/13 .

 Jim Mahoney | cs.bennington.college | MIT License | Aug 2020 
"""

(EMPTY, WALL, BLOCK, PADDLE, BALL) = (0, 1, 2, 3, 4)
(JOY_RIGHT, JOY_LEFT, JOY_CENTER) = (1, -1, 0)
XY_SCORE = (-1,0) # location indicating score, not symbol to mark
symbols = {0: ' ',  # empty
           1: '#',  # wall
           2: '.',  # block
           3: '=',  # paddle
           4: 'o'   # ball
          }

# I found the appropiate joystick motions for automaic control by
# trial and error, printing the the ball and paddle initial positions
# and motion and trying different initial joystick motions.  With this
# start and my day 13 puzzle input, just setting the joystick=+1 when
# the ball is moving right and joystick=-1 when the ball is moving
# left keeps them aligned and tracking correctly. I'm sure the general
# case - other people's say 13 puzzle input - could be coded,
# analyzing the ball and paddle initial motions and coming up with a
# sequence like this to align them, but I have not done that.
INITIAL_AUTO_JOYSTICK = [0,0,0,1] 

def get_code(filename='arcade.intcodemachine'):
    """ Get the machine code for the arcade, a list of numbers. """
    # The arcade.intcode file is my puzzle input from Day 13, Advent of Code 2019.
    # Each registered user gets a slightly different version of the code.
    try:
        with open(filename) as codefile:
            raw = codefile.read().strip()
            code = [int(digits.strip()) for digits in raw.split(',')]
            return code
    except:
        raise Exception(f"Couldn't load intcodemachine from '{filename}'.")

class Arcade:
    """ An arcade game similar to "breakout", 
        running an intcode machine with joystick movement inputs
        and marker position outputs. """
    # The coordinate system uses (x,y) notataion but has (0,0) at top left,
    # and y increasing downward. In other words, (x,y) is a matrix (col,row).
    def __init__(self, terminal, auto=True):
        self.code = get_code()
        self.code[0] = 2  # From instructions, this is how you insert quarters.
        self.machine = IntcodeMachine(code)
        self.tiles = {}
        self.border = 1
        self.ball = None    # (x,y) position of ball
        self.paddle = None  # (x,y) position of paddle
        self.score = 0
        self.v_ball = None
        self.scores = []
        self.auto = auto
        self.terminal = terminal
    def add_input(self, new_input):
        self.machine.inputs.append(new_input)
    def add_inputs(self, new_inputs):
        self.machine.inputs.extend(new_inputs)
    def update(self, machine_outputs):
        index = 0
        while i < len(new_outputs):
            (x,y,tile) = new_outputs[index:index+3]
            self.tiles[(x,y)] = tile
            if tile == BALL:
                if self.ball:
                    # (this_x - last_x); +1 => righward
                    self.v_ball = x - self.ball[0] 
                self.ball = (x,y)
            if tile == PADDLE:
                self.paddle = (x,y)
            if (x,y) == XY_SCORE:
                self.score = tile
            else:
                self.screen.draw_symbol((x,y), self.symbol(tile))
            self.screen.update(score=self.score, blocks=self.count(), step=step)
            index += 3
    def joystick(self):
        """ Return the next joystick motion """
        if self.auto:
            return self.v_ball
        else:
            return self.terminal.joystick()
    def user_joystick(self):
        """ Return next joystick motion from user control """
        return 0  # FIXME
    def run(self):
        _joystick = JOY_CENTER
        max_steps = 10000
        steps = 0
        if self.auto: self.add_inputs(INITIAL_AUTO_JOYSTICK)
        while True:
            steps += 1
            if steps > max_steps: return
            self.add_input(_joystick)
            machine_outputs = self.machine.run()
            self.update(machine_outputs)
            if self.machine.is_halted(): return
            _joystick = self.joystick()
    def count(self, what=BLOCK):
        count = 0
        for xy in self.tiles:
            if self.tiles[xy] == what:
                count += 1
        return count
    def symbol(self, xy):
        return symbols[self.tiles[xy]] if xy in self.tiles else symbols[0]
    
    #def _edge(self, index, minmax):
    #    """ return distance from center to one of the panel edges """
    #    extra = -self.border if minmax == min else self.border
    #    return extra + (0 if not self.tiles else minmax(p[index] for p in self.tiles))
    #def left_edge(self): return self._edge(0, min)
    #def right_edge(self): return self._edge(0, max)
    #def bottom_edge(self): return self._edge(1, max)
    #def top_edge(self): return self._edge(1, min)
    #def screen(self):
    #    """ return printable string of tiles on a grid """
    #    result = ''
    #    for y in range(self.bottom_edge()):
    #        for x in range(self.right_edge()):
    #            if (x,y) != XY_SCORE:
    #                result += self.symbol((x,y))
    #        result +='\n'
    #    for x in range(self.right_edge()):
    #        result += f"{x:02}"[-2]
    #    result += '\n'
    #    for x in range(self.right_edge()):
    #        result += str(x)[-1]
    #    result += '\n'
    #    result += f"score={self.score}  ball={self.ball}  paddle={self.paddle}\n"
    #    return result
        
class Terminal:
    """ A curses terminal screen """
    def __init__(self):
        self.last_joystick = 0      # one of (-1, 0, 1)
        self.start()
    def start(self):
        self.stdscr = curses.initscr()
        curses.noecho()
        curses.cbreak()
        curses.keypad(True)
        curses.nodelay(True)
    def end(self):
        curses.nocbreak()
        curses.keypad(False)
        curses.echo()
        curses.nodelay(False)
        curses.endwin()
    def update(self, score=0, blocks=None, step=0):
        # draw messages at bottom of screen & refresh
        # ...
        self.stdscr.refresh()
    def draw_symbol(self, point, symbol):
        # draw one symbol at the given position
        (x,y) = point
        self.stdscr.addch(y, x, symbol)
    def joystick(self):
        # return position of joystick, i.e. -1, 0, or 1
        key = self.stdscr.getch()
        if key == curses.KEY_RIGHT:
            return 1
        elif key == curses.KEY_LEFT:
            return -1
        else:
            return 0

def main():
    print(' -- arcade game --')
    auto_response = input(' Manual play? (y/n) ')
    auto = auto_response[0] == 'y'
    #
    try:
        terminal = Terminal()
        arcade = Arcade(terminal, auto)
        arcade.play()
        terminal.end()
    except Exception as e:
        terminal.end()       # restore terminal so we can see errors
        raise e

if __name__ == '__main__':
    main()                       
