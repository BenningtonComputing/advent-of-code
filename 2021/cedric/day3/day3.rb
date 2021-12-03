# ADVENT OF CODE DAY 3333333

## Problem 1:
def count_most(input) 
	count = input.tally
	count = count.sort_by { |i,number| number}.last[0]
	return count
end

def calculate_gamma_rate(inputs)
	str = ""
	(0..inputs[0].length - 1).each do|i|
		arr = []
		inputs.each { |n| arr << n[i] }
		str += count_most(arr)
	end
	
	return str.to_i(2)
end

def calculate_epsilon_rate(str_len, gamma)
	epsilon = (str_len - 1).downto(0).map { |n| (~gamma)[n] }.join.to_i(2)
end

File.open("input.txt", "r") do |f|
	inputs = []
	f.each_line do |line|	
		inputs << line
	end	

	str_len = inputs[0].length - 1
	gamma = calculate_gamma_rate(inputs)
	epsilon = calculate_epsilon_rate(str_len, gamma)

	puts "Goldstar 1:"
	puts gamma * epsilon
end

