class_name Num
extends Reference

# Custom class for big numbers - made by 7w1, somewhat based off of ChronoDK's Godot Big Number Class
#
# It does not support negative numbers. It currently only supports precision up to 0.000000001
# It (Godot) supports numbers up to 9.99e9223372036854775807 (64 bit limit)
# But some platforms (when exported) only support up to 9.99e2147483647 (32 bit limit)
# I would recommend trying not to pass the latter
# If you pass the limit the exponent will wrap around and cause a bunch of issues
#
# I only made the functions I needed for Pixel That in this, so if anyone wants to finish up other
# useful number things feel free to let me know and I can add it to the original
#
# Create a number using Num.new("1e1...") or Num.new(1000) if the number is above 9.99e5 (999,999.99...) you must use scientific notation
# Clone a number using Num.new(a)
#
# Make sure the numbers you put in are ALL Num objects and not normal integers,
# If you want to use small numbers just wrap them in Num.new("number") or Num.new(number_variable)
#
# For saving your games data using this, you should be able to use godots store_var(a) function,
# or you can just do a.get_raw(), and a.load_raw(a) to load it
#
##### OPERATIONS #####
#
# Add to a number: 									a.add(b)
# Get the sum of two numbers without modfying them: a.add(a,b)
# Subtract from a number: 							a.sub(b)
# Subtract two numbers without modfying them: 		a.sub(a,b)
# Multiply a number: 								a.multi(b)
# Multiply two numbers without modfying them: 		a.multi(a,b)
# Divide a number: 									a.div(b)
# Divide two numbers without modfying them: 		a.div(a,b)
#
##### COMPARISONS #####
#
# Equal - 					a.is_equal_to(b)
# Less than - 				a.less_than(b)
# Less than or equal to - 	a.less_than_or_equal_to(b)
# Greater than - 			a.greater_than(b)
# Greater than - 			a.greater_than_or_equal_to(b)
#
#######################

var number: float = 0.0
# Why 6? no idea but for some reason it works
var exponent: int = 6

var number_precision = 0.000000001

const MAX_NUMBER = 10.000000000

func _init(n):
	if typeof(n) == TYPE_STRING:
		var sci = n.split("e")
		number = float(sci[0])
		if sci.size() > 1:
			exponent = int(sci[1])
			if exponent < 6:
				while exponent < 6:
					number /= 10
					exponent+=1
		else:
			number /= 1000000
			exponent = 6
	elif typeof(n) == TYPE_OBJECT:
		if n.is_class("Num"):
			number = n.number
			exponent = n.exponent
	else:
		pass

func get_string():
	if exponent == 6:
		return format_num(number*1000000)
	elif exponent > 6:
		var n = "%.2f" % (number)
		if float(n) >= 10:
			n = str(float(n)/10)
			return "%.2f" % (float(n))+"e"+str(exponent+1)
		else:
			return n+"e"+str(exponent)

func get_num():
	return self

func format_num(n):
	if n > 10000000:
		return
	else:
		if n < 100.0:
			if n < 10:
				return String(stepify(n, .01))
			return String(stepify(n, .1))
		if n < 1000.0:
			return String(floor(n))
		else:
			n = String(floor(n))
			var output := ""
			for i in range(0, n.length()):
				if i != 0 and i % 3 == n.length() % 3:
					output += ","
				output += n[i]
			return output
			
func add(a, b: Num = null):
	if b == null:
		var exp_diff = a.exponent - exponent
		if exp_diff < 200 and exp_diff > -200:
			var scaled_number = a.number * pow(10, exp_diff)
			number += scaled_number
		else:
			if exp_diff <= -200:
				return self
			number = a.number
			exponent = a.exponent
		calculate(self)
		return self
	else:
		var c = get_script().new("0")
		c.number = a.number
		c.exponent = a.exponent
		var exp_diff = b.exponent - c.exponent
		if exp_diff < 200 and exp_diff > -200:
			var scaled_number = b.number * pow(10, exp_diff)
			c.number += scaled_number
		else:
			if exp_diff <= -200:
				return self
			c.number = b.number
			c.exponent = b.exponent
		calculate(c)
		return c
		
func sub(a, b: Num = null):
	if b == null:
		var exp_diff = a.exponent - exponent
		if exp_diff < 200 and exp_diff > -200:
			var scaled_number = a.number * pow(10, exp_diff)
			number -= scaled_number
		else:
			number = -number_precision
			exponent = a.exponent
		if number < 0.0 or exponent < 0.0:
			print("ERROR: Negative values not supported.")
			number = 0.0
			exponent = 6
		calculate(self)
		return self
	else:
		var c = get_script().new("0")
		c.number = a.number
		c.exponent = a.exponent
		var exp_diff = b.exponent - c.exponent
		if exp_diff < 200 and exp_diff > -200:
			var scaled_number = c.number * pow(10, exp_diff)
			c.number -= scaled_number
		else:
			c.number = -number_precision
			c.exponent = b.exponent
		if c.number < 0.0 or c.exponent < 0.0:
			print("ERROR: Negative values not supported.")
			c.number = 0.0
			c.exponent = 6
		calculate(c)
		return c
		
func multi(a, b: Num = null):
	if b == null:
		var new_exponent = a.exponent + exponent
		var new_number= a.number * number
		while new_number >= 10.0:
			new_number /= 10.0
			new_exponent += 1
		number = new_number
		exponent = new_exponent
		calculate(self)
		return self
	else:
		var c = get_script().new("0")
		c.number = a.number
		c.exponent = a.exponent
		var new_exponent = b.exponent + c.exponent
		var new_number= b.number * c.number
		while new_number >= 10.0:
			new_number /= 10.0
			new_exponent += 1
		c.number = new_number
		c.exponent = new_exponent
		calculate(c)
		return c
		
func div(a, b: Num = null):
	if b == null:
		if a.number == 0:
			print("ERROR: Divide by zero (or less than " + str(number_precision)+")")
			return self
		var new_exponent = exponent - a.exponent
		var new_number = number / a.number
		while new_number < 1.0 and new_number > 0.0:
			new_number *= 10.0
			new_exponent -= 1
		number = new_number
		exponent = new_exponent
		calculate(self)
		return self
	else:
		if b.number == 0:
			print("ERROR: Divide by zero (or less than " + str(number_precision)+")")
			return self
		var c = get_script().new("0")
		c.number = a.number
		c.exponent = a.exponent
		var new_exponent = c.exponent - b.exponent
		var new_number = c.number / b.number
		while new_number < 1.0 and new_number > 0.0:
			new_number *= 10.0
			new_exponent -= 1
		c.number = new_number
		c.exponent = new_exponent
		calculate(c)
		return c
		
func is_equal_to(a):
	return a.number == number and a.exponent == exponent

func is_greater_than(a):
	if exponent > a.exponent:
		return true
	elif exponent < a.exponent:
		return false
	else:
		return number > a.number

func is_greater_than_or_equal_to(a):
	if exponent > a.exponent:
		return true
	elif exponent < a.exponent:
		return false
	else:
		return number >= a.number


func is_less_than(a):
	if exponent < a.exponent:
		return true
	elif exponent > a.exponent:
		return false
	else:
		return number < a.number


func is_less_than_or_equal_to(a):
	if exponent < a.exponent:
		return true
	elif exponent > a.exponent:
		return false
	else:
		return number <= a.number
	
func calculate(n):
	while n.exponent < 6:
		n.number *= 0.1
		n.exponent += 1
	while n.number >= 10.0:
		n.number *= 0.1
		n.exponent += 1
	while n.number < 1 && exponent > 6:
		n.number *= 10
		n.exponent -= 1
	if n.number == 0.0:
		n.exponent = 6
	n.number = stepify(n.number, number_precision)
	return n

func get_raw():
	return str(number) + "," + str(exponent)
	
func load_raw(a):
	var b = a.split(",")
	number = int(b[0])
	exponent = int(b[1])
	return self
