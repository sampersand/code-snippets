#!/bin/sh

# This file's an example of why shell programming, especially for POSX-complaint
# shells, is so darn hard to get right. It's showing the progression of a "cdd"
# command, a command which just changes directories to the folder containing its
# argument. (This is actually quite useful, as---at least on macOS---if you drag
# a file into terminal, it pastes its full path in; so you can type `cdd `, 
# drag a file in, hit enter, and then you're now in the folder containing said
# file!)
#
# To make it easier, I've added `#` after lines that I've changed, so you can
# more easily see what's happening.



# Ok! First attempt!
function cdd {
	cd $(dirname $1) #
}



# Oops. Looks like `function` isn't POSIX-compliant, and shells (like `dash`)
# don't understand it. Time to rewrite it in POSIX-compliant style!
cdd () {
	cd $(dirname $1)
}



# Oh, it looks like our user forgot to pass the argument; let's add a usage.
cdd () {
	if [[ $# != 1 ]]; then
		echo usage: $0 file >&2
		return 1
	fi

	cd $(dirname $1)
}



# D'oh! Looks like using `$0` as a shorthand for the program name only works in
# scripts (ie not functions); in ZSH it also works in functions, but this isn't
# portable. Guess we have to type out the name.
cdd () {
	if [[ $# != 1 ]]; then
		echo usage: cdd file >&2
		return 1
	fi

	cd $(dirname $1)
}



# Hmm... our user has decided to use paths with spaces in them, so our command
# fails. Let's quote it. In fact, let's quote _everything_ just to be safe.
cdd () {
	if [[ "$#" != 1 ]]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	cd "$(dirname "$1")"
}



# Ok, all's going well. Until... oh boy their directories/files start with `-`s
# and now `dirname`/`cd` the directory is actually an argument. Let's add `--`
# to fix that.
cdd () {
	if [[ "$#" != 1 ]]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	cd -- "$(dirname -- "$1")"
}


# Apparently, our users are _also_ naming naming directories a literal `-`. So,
# when they type out `cdd -/foo`, our function executes `cd -- -`.
#
# This might seem OK at first glance, but actually cd has a special case: When
# you change directories to exactly the string `-`,  it goes to the previous
# directory you were in. This is useful when doing stuff interactively, but
# not so much when in scripts.
# 
# So, we need to explicitly check for that, and replace it with `./-`.
cdd () {
	if [[ "$#" != 1 ]]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	directory="$(dirname -- "$1")"

	if [[ "$directory" = - ]]; then
		directory=./-
	fi
	cd -- "$directory"
}


# Whoops. `[[ .. ]]` isn't POSIX compliant (even if most shells like Bash and ZSH
# support it). Looks like we gotta use `[ .. ]`.
cdd () {
	if [ "$#" != 1 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	directory="$(dirname -- "$1")"

	if [ "$directory" = - ]; then
		directory=./-
	fi
	cd -- "$directory"
}

# Nice. Our function works, it's been in production for a few weeks, and all's
# going well. Until... we hear from a customer that our function breaks when
# their directory _ends in a newline_. Weird, is that even something we should
# be worried about?
#
# Well, we're trying to be POSIX-compliant. And POSIX states that the _only_
# invalid characters in a path is `\0` (ie NUL). Which means a newline is valid,
# and if we want to be POSIX-compliant, we have to support it.
#
# But what's the problem with that, right? We're quoting everything, so the
# shell should be keeping newlines as-is; after all, that's what quotes are for?
#
# Well, it turns out that our use of `$(...)`, even within quotes, actually
# strips all trailing newlines. Most of the time this is what you want (eg
# `foo=$(echo bar)`; you don't want `foo` to be `bar<NEWLINE>`), but in this
# case, the user's paths end in a newline, and are deleted. Thus, when we run
# `$(dirname 'foo<NEWLINE>/bar')`, we get `foo`, not `foo<NEWLINE>`. Lovely!
#
# The solution is to print out a single character (here, `x`) after `dirname`,
# so that whatever newlines `dirname` prints out won't be the _very last
# characters_, and thus won't be removed by `$(...)`. Then, we just have to
# remove them with parameter expansion.
cdd () {
	if [ "$#" != 1 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	# We can pick any character, but I like `x`.
	directory="$(dirname -- "$1"; echo x)"

	# Remove a `<NEWLINE>x` from the output of the previous command. We add the
	# `?` so the newline that `dirname` is guaranteed to output is also deleted.
	directory="${directory%?x}"

	# Ok, now `directory` is good-to-go!

	if [ "$directory" = - ]; then
		directory=./-
	fi
	cd -- "$directory"
}

# Our users are surely toying with us. Apparently their files contain the
# character sequence `\c`. This does not play well with `echo` (which is a bit
# of a portability nightmare), as POSIX states that if a backslash followed by a
# lower-case `c` is present in an argument to `echo`, nothing else should be
# printed out. The original intent was to suppress the trailing newlines that
# `echo` always adds.
#
# This means if `dirname` or `printf` fails for some reason, if the argument
# they gave was, say, `foo<BACKSLASH>cbar/baz`, then the error message would be
#
#    cdd: unable to get dirname for foo<NO TRAILING NEWLINES>
#
# Not good. Time to use the tried-and-true alternative, `printf`!
cdd () {
	if [ "$#" != 1 ]; then
		echo 'usage: cdd file' >&2
		return 1
	fi

	if directory="$(dirname -- "$1" && echo x)"; then
		exit_status="$?"
		printf 'cdd: unable to get dirname for %s\n' $"1" >&2
		return "$exit_status"
	fi

	directory="${directory%?x}"
	if [ "$directory" = - ]; then
		directory=./-
	fi
	cd -- "$directory"
}


# Whelp, shucks. We've gotten complaints from customers that our `directory` and
# `exit_status` variables are overwriting variables from fns that call `cdd`.
# Easy enough to solve, just add `local directory exit_status` at the start of
# the function, and they're now local!...
#
# ... actually, local variables aren't POSIX complaint. Looks like we'll just
# have to pick variable names no one will ever conceivable use.
#
# (Note, it's possible to _guarantee_ we won't have collisions, but we need to
# use `eval`, and that's another story lol.)
cdd () {
	if __cdd_directory="$(dirname -- "$1" && echo x)"; then
		__cdd_exit_status="$?"
		echo "cdd: unable to get dirname for $1" >&2
		return "$__cdd_exit_status"
	fi

	__cdd_directory="${__cdd_directory%?x}"
	if [ "$__cdd_directory" = - ]; then
		__cdd_directory=./-
	fi
	cd -- "$__cdd_directory"
}

# Urk... Looks like people are complaining that after running `cdd`, their
# environment now has `__cdd_directory` and `__cdd_exit_status`. Guess
# we have to `unset` them before we return.
#
# Although. There's no way to unset a variable _and_ then return it. So we have
# to make use of the only local variables you have: arguments to the function.
cdd () {
	# We still have to use a local variable foo `__cdd_directory`, as the return
	# value of `set -- "$(...)"` is the return value of `set`, and thus we have
	# no way of knowing whether `...` failed. So we just need to make sure to
	# `unset` it.
	if ! __cdd_directory="$(dirname -- "$1" && echo x)"; then
		set -- "$?"
		unset -v __cdd_directory  # use `-v` to only unset variables.
		echo "cdd: unable to get dirname for $1" >&2
		return "$1"
	fi

	set -- "${__cdd_directory%?x}"
	unset -v __cdd_directory

	if [ "$1" = - ]; then
		set -- ./-
	fi
	cd -- "$1"
}

# Oh BOY!!! Looks like our users are using the `CDPATH` POSIX variable. If set,
# when you `cd` to a directory, shells first check each directory within
# `CDPATH` (which is separated via `:`, just like `PATH`) for the directory
# you're trying to change to. If it exists, then the shell goes there _instead_.
#
# This is obviously not the functionality we want, so we must overwrite it.
cdd () {
	if ! __cdd_directory="$(dirname -- "$1" && echo x)"; then
		set -- "$?"
		unset -v __cdd_directory
		echo "cdd: unable to get dirname for $1" >&2
		return "$1"
	fi

	set -- "${__cdd_directory%?x}"
	unset -v __cdd_directory

	if [ "$1" = - ]; then
		set -- ./-
	fi
	CDPATH= cd -- "$1"
}

#---


# AAAnd, it looks like your user has decided to `alias` things to oblivion. You
# could just say it's their fault if they `alias dirname='echo hahahaha'`, but
# let's go through with it.
#
# The solution is to quote _any_ part of the command string. The easiest way to
# do that is to just escape the first character with `\`.
cdd () {
	if ! __cdd_directory="$(\dirname -- "$1" && \echo x)"; then
		\set -- "$?"
		\echo "cdd: unable to get dirname for $1" >&2
		\return "$1"
	}

	\set -- "${__cdd_directory%?x}"
	\unset -v __cdd_directory

	if \[ "$1" = - ]; then
		\set -- ./-
	fi
	CDPATH= \cd -- "$1"
}

# Lastly, to be pedantic, let's make sure each command succeeds before going to
# the next.
cdd () {
	if ! __cdd_directory="$(\dirname -- "$1" && \echo x)"; then
		\set -- "$?" || \return 1
		\echo "cdd: unable to get dirname for $1" >&2 || \return 1
		\return "$1" # no need to `||` here, return always succeeds
	}

	\set -- "${__cdd_directory%?x}" || \return 1
	\unset -v __cdd_directory || \return 1

	if \[ "$1" = - ]; then
		\set -- ./- || \return
	fi
	CDPATH= \cd -- "$1" # don't need to `|| return 1` here, as it's the last stmt
}

# And there you have it. A (mostly) portable version of `cdd`; Shells can still
# mess this up, eg with ZSH's global aliases. And, don't even get me started 
# with symlinks lol. But this is POSIX-compliant, so let's roll with it. 
