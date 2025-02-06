
spreadsheet = {}

def set_val(key, value):
	spreadsheet[key] = value

def get_val(key):
	value = spreadsheet[key]

	if type(value) == int:
		return value
	elif type(value) == str:
		return value
	elif type(value) == list:
		total = 0

		for element in value:
			if type(element) == int:
				total += element
			elif type(element) == str:
				total += get_val(int(element))

		return total

# Previous test cases
set_val(1, 34)
set_val(10_000_000, "Hello")

assert get_val(1) == 34
assert get_val(10_000_000) == "Hello"

# Set index 2 to the formula!
set_val(2, [3, "1", 9])
assert get_val(2) == 46

# Now try updating the value at 1 and see it change!
set_val(1, 0)
assert get_val(2) == 12
