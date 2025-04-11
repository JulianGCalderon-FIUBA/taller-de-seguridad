#!/bin/sh

INPUT="Makefile"

printf "Usage:\n\n"

awk '/[a-z0-9]+:/ {
	usage = match(previous, /^## (.*)/)
	if (usage) {
	recipe = $0
	gsub(":.*$", "", recipe)
		usage = substr(previous, RSTART + 3, RLENGTH);
		printf "  \x1b[32;01m%-20s\x1b[0m %s\n", recipe, usage
	}
}
{ previous = $0 }
' < "$INPUT"
