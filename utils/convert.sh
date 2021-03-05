#! /bin/bash

PROGNAME=${0##*/}

# Stolen from https://www.mobilefish.com/services/latin_utf_base64_to_hex/latin_utf_base64_to_hex.php
#
# UTF-8 is a multibyte encoding that can represent any Unicode character in 1
# to 4 bytes:
#
# ASCII characters (U+0000 to U+007F) take 1 byte:
#
# XXXXXXXX
#
# Code points U+0080 to U+07FF take 2 bytes:
#
# The Most Significant Byte (MSB) always start with 110.
# The next byte always start with 10.
#
# 110XXXXX 10XXXXXX
#
# Code points U+0800 to U+FFFF take 3 bytes:
#
# The Most Significant Byte (MSB) always start with 1110.
# The next bytes always start with 10.
#
# 1110XXXX 10XXXXXX 10XXXXXX
#
# Code points U+10000 to U+10FFFF take 4 bytes:
#
# The Most Significant Byte (MSB) always start with 11110.
# The next bytes always start with 10.
#
# 11110XXX 10XXXXXX 10XXXXXX 10XXXXXX
#
# It is recommended to use UTF-8 for Western texts (English, French, German, etc)
# where ASCII is predominant, but not for Asian texts.
#

##
# die		- print a message and exit
#
# arg1		- exit code
# arg2		- message to print
function die
{
	local exitcode=${1}
	local msg="${2}"

	[[ -n "${msg}" ]] && echo "${PROGNAME}: ${msg}" 1>&2

	exit ${exitcode}
}

##
# getUnicodeValue	- convert unicode hex string to integer
#
# arg1			- hex unicode string
function getUnicodeValue
{
	local unicodeString="${1}"

	# convert to uppercase as the stoneage tool BC needs this
	unicodeString=$(echo -n "${unicodeString}" | tr '[a-fu]' '[A-FU]')

	# verify if the format is correct
	[[ "${unicodeString:0:2}" != "U+" ]] && die 1 "incorrect unicode format"

	# convert hex string to integer
	echo -e "obase=10\nibase=16\n${unicodeString:2}" | bc
}

##
# convertToUTF8	- Convert a unicode string to utf-8
#
# arg		- unicode string U+0000 to U+10FFFF
function convertToUTF8
{
	local unicodeString="${1}"
	local unicodeValue=$(getUnicodeValue "${unicodeString}")
	local bytes=0

	# determine how many bytes we need
	[[ ${bytes} -eq 0 && ${unicodeValue} -lt 128 ]] && bytes=1
	[[ ${bytes} -eq 0 && ${unicodeValue} -lt 2048 ]] && bytes=2
	[[ ${bytes} -eq 0 && ${unicodeValue} -lt 65536 ]] && bytes=3
	[[ ${bytes} -eq 0 && ${unicodeValue} -lt 1114112 ]] && bytes=4

	if [[ ${bytes} -eq 1 ]]; then
		# regular ascii value
		printf "\\\x%02X\n" ${unicodeValue}
	elif [[ ${bytes} -eq 2 ]]; then
		local byte1=$(( 192 | ((${unicodeValue} >> 6) & 31 ) ))
		local byte2=$(( 128 | (${unicodeValue} & 63) ))

		printf "\\\x%02X\\\x%02X" ${byte1} ${byte2}
	elif [[ ${bytes} -eq 3 ]]; then
		local byte1=$(( 224 | ((${unicodeValue} >> 12) & 15 ) ))
		local byte2=$(( 128 | ((${unicodeValue} >> 6) & 63 ) ))
		local byte3=$(( 128 | (${unicodeValue} & 63) ))

		printf "\\\x%02X\\\x%02X\\\x%02X" ${byte1} ${byte2} ${byte3}
	elif [[ ${bytes} -eq 4 ]]; then
		local byte1=$(( 240 | ((${unicodeValue} >> 18) & 7 ) ))
		local byte2=$(( 128 | ((${unicodeValue} >> 12) & 63 ) ))
		local byte3=$(( 128 | ((${unicodeValue} >> 6) & 63 ) ))
		local byte4=$(( 128 | (${unicodeValue} & 63) ))

		printf "\\\x%02X\\\x%02X\\\x%02X\\\x%02X" ${byte1} ${byte2} ${byte3} ${byte4}
	fi
}

# a few examples:

# powerline arrow
s="u+e0b0"; rval=$(convertToUTF8 "${s}"); echo -n "${s}: ${rval}: "; echo -e "${rval}"

# chinese symbol for dragon
s="u+9f99"; rval=$(convertToUTF8 "${s}"); echo -n "${s}: ${rval}: "; echo -e "${rval}"

# telefoon receiver
s="u+1f4de"; rval=$(convertToUTF8 "${s}"); echo -n "${s}: ${rval}: "; echo -e "${rval}"
