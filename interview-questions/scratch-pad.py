spreadsheet = {}

def set_val(cell_index, value):
	spreadsheet[cell_index] = value

def get_val(cell_index):
	cell_contents = spreadsheet[cell_index]

	if type(cell_contents) == str or type(cell_contents) == int:
		return cell_contents

	if type(cell_contents) != list:
		print("OOPS! only str, int, or lists are understood!")
		quit()

	# We know cell_contents is a list!
	total = 0

	# formula_part := integer (the number itself) or string (a cell index)
	for formula_part in cell_contents:
		if type(formula_part) == int:
			# formula_part := an int (the number itself)
			total = total + formula_part
		elif type(formula_part) == str:
			# formula_part := a string (a cell index)
			total = total + get_val(int(formula_part))
			# ???
		else:
			print("unknown formula_part type", type(formula_part))
			quit()

	return total

set_val(1, 34);								# A1 = 34
set_val(5, [3, "1337"]);					# A5 = 3 + A1337
set_val(9, [3, 4]);							# A9 = 3 + 4
set_val(1337, [3, 4, "9", 23, "5"]);	# A1337 = 3 + 4 + A9 + 23 + A5
set_val(10_000_000, "Hello");	 			# A10_000_000 = "Hello"

get_val(5)
# print(get_val(1337)) #==> get_val(9)  get_val(1)

# assert get_val(1) == 34
# assert get_val(10_000_000) == "Hello"
# # assert get_val(1337) == 98
