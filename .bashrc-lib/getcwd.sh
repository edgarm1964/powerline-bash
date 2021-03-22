#! /bin/bash

function __get_cwd
{
	local __pwd=${PWD/${HOME}/\~}

	printf "${__pwd##[\~/]*/}"
}
