import sys

class Planet:
    def __init__(self, front, back):
        self.front = front
        self.back = back

    def orbitting(self):
        if self.front == None:
            return 0
        else:
            orbit = self.front.orbitting() + 1
            return orbit

raw_inp = open(sys.argv[1], "r")

planets_dict = {}

line = raw_inp.readline()
while line:
    line_split = line.split(")")
    front = line_split[0]
    back = line_split[1][:-1]

    if front not in planets_dict:
        planets_dict[front] = Planet(None, [])
    if back not in planets_dict:
        planets_dict[back] = Planet(None, [])

    planets_dict[front].back.append(planets_dict[back])
    planets_dict[back].front = planets_dict[front]

    line = raw_inp.readline()

#part 1
out = 0
for key in planets_dict:
    out += planets_dict[key].orbitting()
print(out)

#part 2
#basically: dist bw YOU and SAN is the sum of diff nodes on
#YOU and SAN path's to COM
#generate YOU and SAN set
curr = [planets_dict["YOU"], planets_dict["SAN"]]
sets = [set(), set()]
for i in range(len(curr)):
    while curr[i] != planets_dict["COM"]:
        curr[i] = curr[i].front
        sets[i].add(curr[i])

#path calculation
print(len(sets[0]) + len(sets[1]) - len(sets[0].intersection(sets[1])) * 2)

raw_inp.close()
