'''
Building my own toolkit
'''

def inputfile(directory, lines = True):
	'''takes in the directory of the file and reads it'''
	if lines == True:
		file =  open(directory,'r').readlines()
		return [x.strip() for x in file]  # getting rid of the new line expresssion
	else:
		return  open(directory).read().strip()

def turn_list_to_int(list_):
	"""converts elements of a list to integer"""
	list_ = [int(i) for i in list_]
	return list_

def binary_to_decimal(string):
	"""converts binary number to decimal system"""
	n = len(string)
	dec = 0
	for i in range(1, n+1):
		dec += int(string[-i]) * 2 ** (i-1)
	return dec

def str_to_tup(str_):
	"""converts a string of numbers (integers) separated by comma to a n-tuple"""
	list_ = str_.split(',')
	tup = tuple([int(i) for i in list_])
	return tup

