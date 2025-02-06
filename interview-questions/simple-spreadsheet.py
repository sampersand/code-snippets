spreadsheet = {}

def set_val(key, value):
	spreadsheet[key] = value

def get_val(key):
	return spreadsheet[key]

set_val(1, 34)
set_val(10_000_000, "Hello")

assert get_val(1) == 34
assert get_val(10_000_000) == "Hello"
