#!/bin/sh

if [ -x /usr/local/bin/kanata ]; then
	exec sudo /usr/local/bin/kanata "$@"
elif [ -x /opt/homebrew/bin/kanata ]; then
	exec sudo /opt/homebrew/bin/kanata "$@"
else
	echo "kanata not found in /usr/local/bin or /opt/homebrew/bin" >&2
	exit 1
fi
