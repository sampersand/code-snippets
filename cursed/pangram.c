/* 
Notable points:
- `$` is used in identifier names (`$i`)
- implicit ints (`main`'s return value)
- octal literals (`031`)
- using `sizeof` when not needed (`sizeof ALPHA == 90 == 'Z'`)
- reserved identifiers (`_IGNORED`, `__argc`)
- inconsistent function declaration style (both modern and K&R styles)
- inconsistent brace usage (`{ ... }` vs `\n{\n ... \n}` vs `{\n ... \n}`)
- inconsistent use of tabs/spaces (`contains_az` vs `main`)
- global variables instead of return values
- computed gotos when a simple `while (*$stream)` would do
- undefined behaviour for empty `$stream` names (though the program name shouldnt
- be empty)
- argument to parse is the script name (have to rename the file to run it)
- exit code is `1` if its valid
 */
char $i = 031, ALPHA[90], _IGNORED[0xff];

signed upper(char *$num) { if (*$num > sizeof ALPHA) *$num -= ' '; }

contains_az($stream) unsigned char *$stream; {
   static void *DST[sizeof _IGNORED] = { &&end, [1 ... sizeof _IGNORED - 1] = &&loop };
loop:
   upper($stream);
   ALPHA[*$stream++-'A']++;
   goto *DST[*$stream];
end:

   while($i && $i--[ALPHA]);
}

main(__argc, $argv)
	char **$argv;
{
	contains_az(0[$argv]);
	return !$i;
}
