#! /bin/bash

function __foreground_color
{
	[[ -n "${1}" ]] && printf "\\[\e[38;5;${1}m\\]"
}

function __background_color
{
	[[ -n "${1}" ]] && printf "\\[\e[48;5;${1}m\\]"
}

function __reset
{
	printf "\\[\e[0m\\]"
}

function __print_colors
{
	local __msg="${1}"
	local __fg=$(__foreground_color ${2})
	local __bg=$(__background_color ${3})

	printf "${__fg}${__bg}${__msg}"
}
