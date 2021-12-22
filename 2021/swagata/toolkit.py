'''
Building my own toolkit
'''

import numpy as np

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

########## Array stuff

def list_to_arr(list_):
	"""Turns a list of rows to an array"""
	arr = [[j for j in i] for i in list_]
	arr = np.array(arr,dtype=np.dtype('U100'))
	return arr

def get_neighbors(x, y, arr):
	"""returns the list with four members of an array"""
	neighbor = [arr[x, y +1], arr[x,y-1], arr[x-1,y],arr[x+1,y]]
	return neighbor

def all_neighbors(x,y,arr):
	"""Returns all neighbors including diagonals"""
	neighbors = []
	for i in [-1,0,1]:
		for j in [-1,0,1]:
			neighbors.append((x+i,y+j))
	neighbors = [i for i in neighbors if i != (x,y)]
	return neighbors	


def array_value(postiion, arr):
    """Returns the value at an array from the tuple"""
    row, col = postiion[0], postiion[1]
    value = arr[row, col]
    return value


def add_padding(arr, x):
	"""adds a layer of padding around arr with x"""
	rows, columns = len(arr),len(arr[0])
	new_arr = np.full((rows+2, columns +2), x, dtype=np.dtype('U100'))
	new_arr[1:rows+1,1:columns+1] = arr
	return new_arr


