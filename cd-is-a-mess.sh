#!/bin/sh

# This file's an example of why shell programming, especially for POSX-complaint
# shells, is so darn hard to get right. It's showing the progression of a "cdd"
# command, a command which just changes directories to the folder containing its
# argument. (This is actually quite useful, as---at least on macOS---if you drag
# a file into terminal, it pastes its full path in; so you can type `cdd `, 
# drag a file in, hit enter, and then you're now in the folder containing said
# file!)

# Ok! First attempt!
function cdd {
	cd $(dirname $1)
}


# Oops. Looks like `function` isn't POSIX-compliant, and shells (like `dash`)
# don't understand it. rewrite it in POSIX-compliant style
cdd () {
	cd $(dirname $1)
}


# Oh, well it looks like our user forgot to pass the argument; let's handle that.
cdd () {
	cd $(dirname ${1:?missing a file})
}


# Hmm... our user has decided to use paths with spaces in them, so our command
# fails. Looks like we have to quote it.
cdd () {
	cd "$(dirname "${1:?missing a file}")"
}


# Ok, all's going well. Until... oh boy their directories/files start with `-`s
# and now `dirname` (and `cd`) think that the directory is actually an argument. 
# et's add `--` to fix that.
cdd () {
	cd -- "$(dirname -- "${1:?missing a file}")"
}


# Apparently, our users are naming directories `-`. So when they type out
# `cdd -/foo`, our function executes `cd -- -`; cd has a special case, such that
# when you cd to exactly `-`, it goes to the previous directory. So we need to
# check for that, and replace it with `./-`.
cdd () {
	directory="$(dirname -- "${1:?missing a file}")"

	if [[ "$directory" = - ]]; then
		directory=./-
	fi
	cd -- "$directory"
}


# Whoops. `[[` isn't POSIX compliant. Looks like we gotta use `[`
cdd () {
	directory="$(dirname -- "${1:?missing a file}")"

	if [ "$directory" = - ]; then
		directory=./-
	fi
	cd -- "$directory"
}

# Hmm... Well, it looks like the user's directory _ends in a newline_. Weird,
# right? According to POSIX, the _only_ invalid characters in a file path are
# `\0`, and a `/` (which is used to separate folders). So `\n` is valid. Uhhh.
# Well, the problem is that `$(...)` actually strips all trailing newlines, so
# `$(dirname 'foo<NEWLINE>/bar')` is `foo` not `foo<NEWLINE>`. Lovely!
cdd () {
	# Print out `x` at the end, so any preceding newlines aren't the _very_ last
	# character, and as such won't be stripped.
	directory="$(dirname -- "${1:?missing a file}"; printf x)"

	# Remove a `<NEWLINE>x` from the output of the previous command. We add the
	# `?` so the newline that `dirname` is guaranteed to output is also deleted.
	directory="${directory%?x}"

	if [ "$directory" = - ]; then
		directory=./-
	fi
	cd -- "$directory"
}


# Oh, it looks like our users are complaining that our function doesn't work
# properly if either the `dirname` or `printf`s fail. Time to handle errors!~
cdd () {
	# Print out `x` at the end, so any preceding newlines aren't the _very_ last
	# character, and as such won't be stripped.
	directory="$(dirname -- "${1:?missing a file}" && printf x)" || {
		exit_status="$?"
		echo "Unable to get the dirname!" >&2
		return "$exit_status"
	}

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
	__cdd_priv_directory="$(dirname -- "${1:?missing a file}" && printf x)" || {
		__cdd_priv_exit_status="$?"
		echo "Unable to get the dirname!" >&2
		return "$__cdd_priv_exit_status"
	}

	__cdd_priv_directory="${__cdd_priv_directory%?x}"
	if [ "$__cdd_priv_directory" = - ]; then
		__cdd_priv_directory=./-
	fi
	cd -- "$__cdd_priv_directory"
}

# Urk... Looks like people are complaining that after running `cdd`, their
# environment now has `__cdd_priv_directory` and `__cdd_priv_exit_status`. Guess
# we have to `unset` them before we return.
#
# Although. There's no way to unset a variable _and_ then return it. So we have
# to make use of the only local variables you have: arguments to the function.
cdd () {
	__cdd_priv_directory="$(dirname -- "${1:?missing a file}" && printf x)" || {
		set -- "$?"
		echo "Unable to get the dirname!" >&2
		return "$1"
	}

	set -- "${__cdd_priv_directory%?x}"
	unset -v __cdd_priv_directory # use `-v` to only unset variables

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
	__cdd_priv_directory="$(dirname -- "${1:?missing a file}" && printf x)" || {
		set -- "$?"
		echo "Unable to get the dirname!" >&2
		return "$1"
	}

	set -- "${__cdd_priv_directory%?x}"
	unset -v __cdd_priv_directory

	if [ "$1" = - ]; then
		set -- ./-
	fi
	CDPATH= cd -- "$1"
}


# AAAnd, it looks like your user has decided to `alias` things to oblivion. You
# could just say it's their fault if they `alias dirname='echo hahahaha'`, but
# let's go through with it.
#
# The solution is to quote _any_ part of the command string. The easiest way to
# do that is to just escape the first character with `\`.
cdd () {
	__cdd_priv_directory="$(\dirname -- "${1:?missing a file}" && \printf x)" || {
		\set -- "$?"
		\echo "Unable to get the dirname!" >&2
		\return "$1"
	}

	\set -- "${__cdd_priv_directory%?x}"
	\unset -v __cdd_priv_directory

	if \[ "$1" = - ]; then
		\set -- ./-
	fi
	CDPATH= \cd -- "$1"
}

# Lastly, to be pedantic, let's make sure each command succeeds before going to
# the next.
cdd () {
	__cdd_priv_directory="$(\dirname -- "${1:?missing a file}" && \printf x)" || {
		\set -- "$?" || \return 1
		\echo "Unable to get the dirname!" >&2 || \return 1
		\return "$1" # no need to `||` here, return always succeeds
	}

	\set -- "${__cdd_priv_directory%?x}" || \return 1
	\unset -v __cdd_priv_directory || \return 1

	if \[ "$1" = - ]; then
		\set -- ./- || \return
	fi
	CDPATH= \cd -- "$1" # don't need to `|| return 1` here, as it's the last stmt
}

# And there you have it. A (mostly) portable version of `cdd`; Shells can still
# mess this up, eg with ZSH's global aliases. And, don't even get me started 
# with symlinks lol. But this is POSIX-compliant, so let's roll with it. 
