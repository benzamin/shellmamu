#!/bin/sh
#!/usr/bin/env bash
#set -v

COLOR_NONE=`tput sgr0` # No Color
COLOR_RED=`tput setaf 1`
COLOR_GREEN=`tput setaf 2`
COLOR_YELLOW=`tput setaf 3`
COLOR_BLUE=`tput setaf 4`
COLOR_MAGENTA=`tput setaf 5`
COLOR_CYAN=`tput setaf 6`
COLOR_WHITE=`tput setaf 7`
TEXT_BOLD=`tput bold`
TEXT_NORMAL=`tput sgr0`
########### private utility methods ############
contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}
printTipsText()
{
	echo "${COLOR_CYAN}${TEXT_BOLD}::TIPS:: $1 ${COLOR_NONE}"
}
printSuccessText()
{
	echo "${COLOR_GREEN}${TEXT_BOLD}Success: $1 ${COLOR_NONE}"
}
printFailureText()
{
	echo "${COLOR_RED}${TEXT_BOLD}Failure: $1 ${COLOR_NONE}"
}
folderExists(){
	if [ -d "$1" ]; then
  		return 1;
	fi
	return 0;
}
fileExists(){
	if [ -f "$1" ]; then
    	return 1;
	fi
	return 0;
}
readInputFile()
{
	until [ "$FILE_PATH" ]; do
		read -e -p "${COLOR_BLUE}$1 ${COLOR_NONE}" FILE_PATH
	done
	echo $(abspath "$FILE_PATH")
}

readText()
{
	until [ "$INPUT_TEXT" ]; do
		read -p "${COLOR_BLUE} $1 ${COLOR_NONE}" INPUT_TEXT
	done
	echo $INPUT_TEXT
}

ltrim() #{{{1 # Removes all leading whitespace (from the left).
{
    local char=${1:-[:space:]}
    sed "s%^[${char//%/\\%}]*%%"
}
rtrim() #{{{1 # Removes all trailing whitespace (from the right).
{
    local char=${1:-[:space:]}
    sed "s%[${char//%/\\%}]*$%%"
}
trim() #{{{1 # Removes all leading/trailing whitespace
{
	#could've been very simple, like TRIMMED_PATH=`echo "$SOME_PATH" | sed 's/^ *//;s/ *$//'`
    ltrim "$1" | rtrim "$1"
}
squeeze() #{{{1 # Removes leading/trailing whitespace and condenses all other consecutive whitespace into a single space.
{
    local char=${1:-[[:space:]]}
    sed "s%\(${char//%/\\%}\)\+%\1%g" | trim "$char"
}
abspath() #{{{1     # Gets the absolute path of the given path. Will resolve paths that contain '.' and '..'. Think readlink without the symlink resolution.
{
    local path=${1:-$PWD}

    # Path looks like: ~user/...
    # Gods of bash, forgive me for using eval
    if [[ $path =~ ~[a-zA-Z] ]]; then
        if [[ ${path%%/*} =~ ^~[[:alpha:]_][[:alnum:]_]*$ ]]; then
            path=$(eval echo $path)
        fi
    fi

    # Path looks like: ~/...
    [[ $path == ~* ]] && path=${path/\~/$HOME}

    # Path is not absolute
    [[ $path != /* ]] && path=$PWD/$path

    path=$(squeeze "/" <<<"$path")

    local elms=()
    local elm
    local OIFS=$IFS; IFS="/"
    for elm in $path; do
        IFS=$OIFS
        [[ $elm == . ]] && continue
        if [[ $elm == .. ]]; then
            elms=("${elms[@]:0:$((${#elms[@]}-1))}")
        else
            elms=("${elms[@]}" "$elm")
        fi
    done
    IFS="/"
    echo "/${elms[*]}"
    IFS=$OIFS
}

#helpText#$ mamu help (Prints help for all available commands)
help()
{
	echo "${COLOR_MAGENTA}------------------------------ List of utilities -------------------------------\n"
	sed -n 's/^#helpText#//p' $0
	echo "\n------------------------------------ END ---------------------------------------\n${COLOR_NONE}"
}



################################################################################
####################### Utility Commands functions #############################
################################################################################

#helpText#$ mamu countdown (counts down with voice feedback a certain amount of seconds)
countdown() {
	SECONDS=0
	if [ $# -lt 1 ]
		then
		printTipsText "You can also use countdown command like - $ mamu countdown 10 "
		SECONDS=$(readText "How many seconds you want to countdown? -> ")
	else
		SECONDS=$1
	fi

	for (( i=SECONDS; i>0; i--)); do
				  sleep 1 &
				  printf "  $i \r"
				  say $i
				  wait
			done
		say 'countdown done'
}

#helpText#$ mamu findnreplace (finds given text and replaces it with a new one in a file)
findnreplace(){

	FILE_NAME=""
	FIND_TEXT=""
	REPLACE_TEXT=""

	if [ $# -lt 3 ]
		then
		printTipsText "You can also use findnreplace command like - $ mamu findnreplace /Desktop/myFile.txt 'Old text' 'New text'"
		FILE_NAME=$(readInputFile  "In which file you want to find a replace text?  -> ")
		FIND_TEXT=$(readText "Which text you want to find? -> ")
		REPLACE_TEXT=$(readText "What text you want to replace with? -> ")
	else
		FILE_NAME=$1
		FIND_TEXT=$2
		REPLACE_TEXT=$3
	fi
	##remove the white spaces
	FILE_NAME=`echo "$FILE_NAME" | sed 's/^ *//;s/ *$//'`

	sed -i.bak "s/$FIND_TEXT/$REPLACE_TEXT/g" $FILE_NAME

	DIRECTORY_NAME=$(dirname "$FILE_NAME")
	rm $DIRECTORY_NAME//*".bak"
}

#helpText#$ mamu findtext (finds given text in a file or folder and shows a list of them)
findtext()
{
	SEARCH_TEXT=""
	SEARCH_PATH=""

	if [ $# -lt 2 ]
		then
		printTipsText "You can also use findtext command like - $ mamu findtext 'love' ~/Desktop/Song-Lyrics"
		SEARCH_PATH=$(readInputFile "Which file/folder you want to search? ${COLOR_NONE}->")
		SEARCH_TEXT=$(readText "What text you want to search in files?  -> " )
	else
		SEARCH_PATH=$(abspath "$1")
		SEARCH_TEXT="$2"

	fi

	grep -irw -n  $SEARCH_PATH -e "$SEARCH_TEXT"
	#grep --include=\*.{c,h} -rnw '/path/to/somewhere/' -e "pattern"
	#grep --exclude=*.o -rnw '/path/to/somewhere/' -e "pattern"
}

#helpText#$ mamu symboliclink (make a symbolic link of a file/folder into another folder)
symboliclink()
{

	SOURCE_PATH=""
	DESTINATION_PATH=""
	if [ $# -lt 2 ]
		then
		printTipsText "You can also use symboliclink command like - $ mamu symboliclink ~/Desktop/Songs/MichelJackson ~/Desktop/FavouriteSongs"
		SOURCE_PATH=$(readInputFile "Which folder/file you want to make symbolic-link of? -> " )
		DESTINATION_PATH=$(readInputFile "Where to put the symbolic-link? -> ")
	else
		SOURCE_PATH=$(abspath "$1")
		DESTINATION_PATH=$(abspath "$2")
	fi

	ln -s $SOURCE_PATH $DESTINATION_PATH

	if [ $? -eq 0 ]; then
    	printSuccessText "Made a symbolic link from $SOURCE_PATH to $DESTINATION_PATH"
	fi
}

#helpText#$ mamu httpserver (starts basic python HTTP server in a given port & directory)
httpserver()
{
	SOURCE_PATH=""
	SERVER_PORT=""
	if [ $# -ne 2 ]; then
        printTipsText "You can also use findnreplace command like - $ mamu httpserver ~/Desktop/MyWebsite 8080"
		SOURCE_PATH=$(readInputFile "Which folder you want to serve as HTTP server? -> " )
		SERVER_PORT=$(readText "What port to use for serving HTTP server? (ex: 8080)  -> " )
		pushd "$SOURCE_PATH"; python -m SimpleHTTPServer $SERVER_PORT; popd
	else
		pushd "$1"; python -m SimpleHTTPServer $2; popd
	fi

}

#helpText#$ mamu killnode (kills all running node.js instances or a given one)
killnode(){

	if [ $# -ne 1 ]; then
        printTipsText "You can also use findnreplace command like - $ mamu killnode app.js"
		kill $(ps aux | grep .js | awk '{print $2}')
		if [ $? -eq 0 ]; then
    		printSuccessText "Killed all node process!"
		fi
	else
		PROCESS_NAME="$1"
		kill $(ps aux | grep $PROCESS_NAME | awk '{print $2}')
		if [ $? -eq 0 ]; then
    		printSuccessText "Killed $PROCESS_NAME node process!"
		fi
	fi
}

#helpText#$ mamu testtls (tests which TLS versions supported on a given website)
testtls()
{
	SERVER=""
	if [ $# -ne 1 ]; then
		printTipsText "You can also use testtls command like - $ mamu testtls https://google.com"
		SERVER=$(readText "What HTTP/S server you want to test? -> " )
	else
		SERVER="$1"
	fi

	function testTLSVersion()
	{
		TLS=$1
		echo "Testing TLS$1 on $SERVER..."
		OUT=$(curl -v --silent --tlsv$TLS https://$SERVER/ 2>&1 | grep TLS)

		if [ -z "$OUT" ]; then
			 printFailureText "TLS$TLS is NOT SUPPORTED on $SERVER"
		else
			printSuccessText "TLS$TLS is supported on $SERVER"
		fi
	}

	testTLSVersion 1.2
	testTLSVersion 1.1
	testTLSVersion 1.0

}

########################################
####### ENTRY POINT OF USER INPUT ######
########################################

if [ $# -lt 1 ]; then
	echo "${COLOR_CYAN}${TEXT_BOLD}\nWelcome to ShellMamu, a collection of shell utilities which ask for arguments. ${COLOR_NONE}"
	help
else
    "$@"
	if [ $? -ne 0 ]; then
		echo "${COLOR_RED}${TEXT_BOLD}Please provide a valid utility name, available utilities are: ${COLOR_NONE}"
		help
	fi
fi
exit


