# ADVENT OF CODE DAY 1111111111111111111111

## Problem 1:

def compare_numbers(input)
	counter = 0
	input.each_with_index do |n, i|
		if i != input.length - 1 && n < input[i+1]
			counter += 1
		end
	end

	return counter
end

## Problem 2:

def compare_windows(input)
	counter = 0
	input.each_with_index do |n, i|
		if i < input.length - 3
			window_1 =  input[i..i+2].sum
			window_2 =  input[i+1..i+3].sum

			counter += 1 if window_1 < window_2
		end
	end

	return counter
end

File.open("input.txt", "r") do |f|
	inputs = []
	f.each_line do |line|	
		inputs << line.to_i
	  end	
	puts "Goldstar 1:"
	puts "#{compare_numbers(inputs)}"
	puts "\nGoldstar 2:"
	puts "#{compare_windows(inputs)}"
end

