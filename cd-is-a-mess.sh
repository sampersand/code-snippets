#!/bin/sh

# This file's an example of why shell programming, especially for POSX-complaint
# shells, is so darn hard to get right. It's showing the progression of a "cdd"
# command, a command which just changes directories to the folder containing its
# argument. (This is actually quite useful, as---at least on macOS---if you drag
# a file into terminal, it pastes its full path in; so you can type `cdd `, 
# drag a file in, hit enter, and then you're now in the folder containing said
# file!)


################################################################################
#                                                                              #
#                                First Attempts                                #
#                                                                              #
################################################################################

# Ok! First attempt!
function cdd {
	cd $(dirname $1)
}


# Oh, it looks like our program doesn't work well when the user forgets
# to pass in an argument. Let's add a usage when no arguments are given.
function cdd {
	if [[ $# == 0 ]]; then
		# `$0` is the function/script name; `>&2` prints to stderr.
		echo usage: $0 file >&2
		return 1
	fi

	cd $(dirname $1)
}


################################################################################
#                                                                              #
#                               POSIX Compliance                               #
#                                                                              #
################################################################################

# Oops. While our function might work for most shells, we're aiming at maximum
# portability. This means we must be POSIX-complaint, and so no special shell
# extensions.
#
# POSIX says that functions are declared `name () { ... }`, so let's rewrite it
# in that style.
cdd () {
	if [[ $# == 0 ]]; then
		echo usage: $0 file >&2
		return 1
	fi

	cd $(dirname $1)
}


# Whoops. `[[ .. ]]` isn't POSIX compliant (even if most shells like Bash and
# ZSH support it). Looks like we gotta use `[ .. ]`.
cdd () {
	if [ $# == 0 ]; then
		echo usage: $0 file >&2
		return 1
	fi

	cd $(dirname $1)
}

# Urk, `[ a == b ]` is an extension as well. The correct answer? `[ a = b ]`
cdd () {
	if [ $# = 0 ]; then
		echo usage: $0 file >&2
		return 1
	fi

	cd $(dirname $1)
}


# D'oh! Looks like using `$0` as a shorthand for the program name only works
# within scripts (ie not shell functions). Guess we have to type out the name.
#
# (Note: in ZSH `$0` also works in functions, but since we're being portable, we
# can't rely on that)
cdd () {
	if [ $# = 0 ]; then
		echo usage: cdd file >&2
		return 1
	fi

	cd $(dirname $1)
}


################################################################################
#                                                                              #
#                            Bad User Input: Part 1                            #
#                                                                              #
################################################################################

# Our previous code is fully POSIX-complaint! However, our users have reported a
# problem: Our command fails when their paths have spaces or weird characters
# like `*` in them. Let's fix this by quoting things.
function cdd {
	if [ $# = 0 ]; then
		# Technically you don't need quotes here, but it feels weird not to.
		echo 'usage: cdd file' >&2
		return 1
	fi

	cd "$(dirname "$1")"
}


# Our users now complained that we break when their directories start with `-`s,
# such as `cdd -L/foo/bar`. Kinda their fault for making directories looks like
# flags.
#
# Buuuut, since we want to be portable, let's go ahead and fix it; it's a simple
# enough change, we just add `--` right after the command names, to ensure that
# `dirname`/`cd` wont interpret their arguments as flags.
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	cd -- "$(dirname -- "$1")"
}


# Lastly, while we're here, let's handle the case of when `dirname` fails. We
# don't want to just blindly change directories to whatever `dirname` might
# output if it fails.
#
# The solution to this is to do this in two steps: `directory="$(dirname ...)"`,
# followed by a `cd -- "$directory"`. The key is that the return value of simple
# assignments (i.e. `foo=bar`, not fancy stuff like `export foo=bar`, etc.) are
# guaranteed by POSIX to be the return value of `bar`. Thus, we can do
# `if ! foo=bar; then ...` to handle failures.
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if ! directory="$(dirname -- "$1")"; then
		echo "cdd: unable to get dirname for: $1" >&2
		return 2
	fi

	cd -- "$directory"
}

################################################################################
#                                                                              #
#                               Local Variables                                #
#                                                                              #
################################################################################

# Whelp, shucks. We've gotten complaints from customers that our `directory`
# variable we just introduced is overwriting THEIR `directory` variable. This is
# because in shell scripting, unless you state otherwise, all variables are
# global. Well, that's an easy enough fix, let's just make `directory` local:
cdd () {
	local directory

	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if ! directory="$(dirname -- "$1")"; then
		echo "cdd: unable to get dirname for: $1" >&2
		return 2
	fi

	cd -- "$directory"
}

# Once again, POSIX bites us. Nearly every shell in existence has _some_ form of
# local variables, however the exact syntax they use is slightly different.
#
# Thus, POSIX-compliant functions just can't have local variables. Let's try
# another tactic: Picking a name no one would use.
#
# (There _is_ a way to guarantee you won't have conflicting variable names, but
# it requires use of `eval` and I didn't want to do that in this example.)
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if ! __cdd_directory="$(dirname -- "$1")"; then
		echo "cdd: unable to get dirname for: $1" >&2
		return 2
	fi

	cd -- "$__cdd_directory"
}


# Urk... Looks like people are complaining that after running `cdd`, their
# environment now has `__cdd_directory` in it, and is mucking things up. Let's
# try another approach: Using the only local variables POSIX guarantees you:
# the arguments to the function.
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	# Just like how we need `--` for `cd` and `dirname` to prevent them from
	# interpreting arguments as flags, we also need it for `set`.
	# as arguments to set.

	# We need to keep the original `$1`, so that it can be used for the error!
	if ! set -- "$1" "$(dirname -- "$1")"; then
		echo "cdd: unable to get dirname for $1" >&2
		return 2
	fi

	cd -- "$2" # `$2` is the directory.
}

# Uh oh, it looks like we have a regression: `dirname` failures are no longer
# handled properly, and the script just happily chugs along.
#
# This is because we now do `if ! set ...`, and so we're checking the return
# value of `set`, not the `$(...)` substitution. So, we need a hybrid approach.
#
# Time for a hybrid approach:
#
# We'll use `__cdd_directory`, so that we can check the return value of
# `dirname` (making sure we we `unset` it to prevent it from mucking up the
# enclosing environment). But, since you can't unset a variable and then use it
# (ie you cant `unset __cdd_directory; cd -- "$__cdd_directory"`), we need to
# `set` it.
# the arguments to the function.
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	# Just like how we need `--` for `cd` and `dirname` to prevent them from
	# interpreting arguments as flags, we also need it for `set`. Also, we need
	# to keep the original `$1`, so that it can be used for the error message!
	if ! __cdd_directory="$(dirname -- "$1")"; then
		unset -v __cdd_directory # Make sure to also unset it in the error case!
		echo "cdd: unable to get dirname for $1" >&2
		return 2
	fi

	# We no longer need the old `$1`, as that was just for the error message.
	set -- "$__cdd_directory"
	unset -v  __cdd_directory

	cd -- "$1"
}


################################################################################
#                                                                              #
#                             Even Weirder Inputs                              #
#                                                                              #
################################################################################

# Nice. Our function works, it's been in production for a few weeks, and all's
# going well. What we've written is qutie robust, and for 99% of use cases, will
# work just fine.
#
# Unfortunately for us, our customers are the 1%. We've just heard that our
# code breaks when their directory _ends in a newline_. WHAT?! Who even does
# that?? Them apparently. Do we need to even worry about it?
#
# Well, we're trying to be fully portable. And POSIX states that the _only_
# invalid characters in a path is `\0` (ie NUL). Which means a newline, while
# extremely awkward, is a valid character in a path. So, we must support it.
#
# But, where's the problem arising? We're quoting everything, so the shell
# should keep newlines as-is; after all, that's what quotes are for?
#
# Well, it turns out that our use of `$(...)`, even within quotes, actually
# strips all trailing newlines. Most of the time this is what you want (eg
# `foo=$(echo bar)`; you don't want `foo` to be `bar<NEWLINE>`), but in this
# case, the user's paths end in a newline, and are deleted. Thus, when we run
# `$(dirname -- 'foo<NEWLINE>/bar')`, we get `foo`, not `foo<NEWLINE>`. Lovely!
#
# The solution is to print out a single character (here, `x`) after `dirname`,
# so that whatever newlines `dirname` prints out won't be the _very last
# characters_, and thus won't be removed by `$(...)`. Then, we just have to
# remove them with parameter expansion.
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	# Make sure we use `&&` instead of `;`. If we used `; echo x`, any failures
	# of `dirname` wouldn't be caught, and we'd have another regression.
	if ! __cdd_directory="$(dirname -- "$1" && echo x)"; then
		unset -v __cdd_directory
		echo "cdd: unable to get dirname for $1" >&2
		return 2
	fi

	# Remove a `<NEWLINE>x` from the output of the previous command. We add the
	# `?` so the newline that `dirname` is guaranteed to output is also deleted.
	set -- "${__cdd_directory%?x}"
	unset -v  __cdd_directory

	cd -- "$1"
}

# Cool, that works. Mostly. Our users must be toying with us.
#
# We've now received a complaint that the error message for when we're unable to
# get a dirname is no longer printing the first argument properly. Apparently,
# the path contains a backslash followed by a lower-case `c`.
#
# This does not play well with `echo`, as POSIX states that if a backslash
# followed by a lower-case `c` is present in an argument to `echo`, then all
# remaining output should be suppressed. (The original intent was to suppress
# trailing newlines that `echo` always adds; This, along with a bunch of other
# gotchas, are why you should never use `echo` in portables scripts for anything
# other than string literals.)
#
# This means if the `dirname` or `echo` fails, and the argument to `cdd` was,
# say, `foo<BACKSLASH>cbar/baz`, then the error message would be :
#
#    cdd: unable to get dirname for foo<NO TRAILING NEWLINE>
#
# Not good. The solution? Just don't use `echo` here and opt for `printf`.
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if ! __cdd_directory="$(dirname -- "$1" && echo x)"; then
		unset -v __cdd_directory
		printf 'cdd: unable to get dirname for %s\n' "$1" >&2
		return 2
	fi

	set -- "${__cdd_directory%?x}"
	unset -v  __cdd_directory

	cd -- "$1"
}

# One more bizarre piece of user input we should handle: Have you noticed that
# this entire time `$#` has been unquoted? It makes sense after all, `$#` is
# guaranteed to just be a number (no spaces or funky characters like `*`).
#
# However, try this out: `IFS=0 cdd $(seq 1 100)`. You'll probably get a lovely
# error message like `[: unexpected operator`. This is because unquoted vars
# are split on spaces/tabs/newlines by default, but you can change that via the
# `IFS` variable. If you set it to a number, `$#` might accidentally be split
# apart. So, we have to quote it.
cdd () {
	if [ $# = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if ! __cdd_directory="$(dirname -- "$1" && echo x)"; then
		unset -v __cdd_directory
		printf 'cdd: unable to get dirname for %s\n' "$1" >&2
		return 2
	fi

	set -- "${__cdd_directory%?x}"
	unset -v  __cdd_directory

	cd -- "$1"
}

################################################################################
#                                                                              #
#                                  CD Quirks                                   #
#                                                                              #
################################################################################

# Even with everything we've done so far, we still are finding errors. Another
# complaint, this time from a user who typed in `cdd -/foo`, and complained they
# somewhere completely unexpected.
#
# What's the problem with this? `cdd -/foo` eventually runs `cd -- -`, and we
# put those `--`s there to force `cd` to not interpret its arguments as flags.
#
# Unfortunately, `cd` has an edge case: If the directory you're changing to
# is the literal string `-` (but not `-/`), then `cd` will actually go to the
# directory you _previously_ were in. (i.e. `cd /foo; cd /bar; cd -` will bring
# you to `/foo` again.) This is actually quite useful in interactive use, but
# for scripts like ours, it's a bit annoying.
#
# So, we need to explicitly add a check for it, and replace it with `-/`
cdd () {
	if [ "$#" = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if ! __cdd_directory="$(dirname -- "$1" && echo x)"; then
		unset -v __cdd_directory
		printf 'cdd: unable to get dirname for %s\n' "$1" >&2
		return 2
	fi

	set -- "${__cdd_directory%?x}"
	unset -v  __cdd_directory

	if [ "$1" = - ]; then
		set -- -/
	fi

	cd -- "$1"
}


# You get a new email. "BUG REPORT: cdd FAILS when `CDPATH` is set". Ugh, again.
# You read the contents of the email: Apparently, a user has decided to set the
# `CDPATH` variable, and now our function fails.
#
# After doing some quick searching, you find that if `CDPATH` is set and the
# argument to `cd` is not an absolute path, then `cd` changes its behaviour.
# Instead of `cd foo` being equivalent to `./foo`, it instead searches all of
# `CDPATH`'s directories '(which is separated via `:`, just like `PATH`) to see
# if any of those contain `foo`. If they do, `cd` instead _goes to that foo_.
# 
# The user is complaining that they expected `cdd` to always just go to the
# parent directory, instead of following `CDPATH`. There's a few solutions here:
#
# The first is to just tell the user to do `CDPATH= cdd ...`; that way, the `cd`
# that `cdd` uses won't see their `CDPATH`. This is probably the "best" option,
# as then users can pick-and-choose when they want `cdd` to respect `CDPATH` or
# not. (And, if they have `CDPATH` set, they hopefully know what they're doing.)
#
# The second is for `cdd` itself to do `CDPATH= cd -- "$1"`. That is, disable
# CDPATH just for the `cd` command. This is also valid, as users might not
# realize they have CDPATH enabled.
#
# The third option is to just prepend `./` to all non-absolute paths. This
# ensures that `CDPATH` won't be queried. This is also valid, but if users want
# to provide a custom `cd`, then we'll be changing the string they get.
#
# I've gone ahead with option 2 for simplicity
cdd () {
	if [ "$#" = 0 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if ! __cdd_directory="$(dirname -- "$1" && echo x)"; then
		unset -v __cdd_directory
		printf 'cdd: unable to get dirname for %s\n' "$1" >&2
		return 2
	fi

	set -- "${__cdd_directory%?x}"
	unset -v  __cdd_directory

	if [ "$1" = - ]; then
		set -- -/
	fi

	CDPATH= cd -- "$1"
}

# And there you have it; that's my `cdd` command I personally use, as it's
# pretty robust, but still marginally readable.

################################################################################
#                                                                              #
#                                     ZSH                                      #
#                                                                              #
################################################################################


# For what it's worth, here's what I do in ZSH.
cdd () CDPATH= cd -- ${${${1:?missing a file}:h}/#%-/-/}

# And here's that expanded out.
cdd () {
	# Ensure the first arg was provided; `: ${a:?...}` is traditional shell
	# shorthand for validating arguments are provided
	: ${1:?missing a file}

	# In ZSH, `${var:h}` is the dirname of `var` without any of the silly hacks
	# we had to do.
	local enclosing_directory=${1:h} 

	# In ZSH, `${var/#%pat/repl}` expands out to `$var`, unless it exactly
	# matches `pat`, in which case it expands out to `repl`. In this case, the
	# `pat` is `-`, and the `repl` is `-/`.
	#
	# I only used this pattern matching thing to make it work in one line in the
	# short example earlier lol. Realistically, I'd do an if sta\tement.
	local fix_single_hyphen=${enclosing_directory/#%-/-/}

	# Go to the directory
	CDPATH= cd -- $fix_single_hyphen
}
