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
