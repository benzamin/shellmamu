#!/bin/sh
set -v

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

countDown() {
	SECONDS="$1"
	for (( i=SECONDS; i>0; i--)); do
				  sleep 1 &
				  printf "  $i \r"
				  say $i
				  wait
			done
		say 'countdown done'
}

findNreplace(){
	##remove the white spaces
	FILE_NAME=`echo $1 | sed 's/^ *//;s/ *$//'`
	FIND_TEXT="$2"
	REPLACE_TEXT="$3"
	
	echo $FILE_NAME$FIND_TEXT $REPLACE_TEXT

	sed -i.bak "s/$FIND_TEXT/$REPLACE_TEXT/g" $FILE_NAME

	DIRECTORY_NAME=$(dirname "$FILE_NAME")
	rm $DIRECTORY_NAME//*".bak"
}

findText()
{
	SEARCH_TEXT=$1
	SEARCH_PATH=`echo $2 | sed 's/^ *//;s/ *$//'`
	
	grep -irw -n  $SEARCH_PATH -e $SEARCH_TEXT
	#grep --include=\*.{c,h} -rnw '/path/to/somewhere/' -e "pattern"
	#grep --exclude=*.o -rnw '/path/to/somewhere/' -e "pattern"
} 


if [ $# -lt 1 ]; then
	echo "Plese provide a path Utility name, like countdown, findNreplace"
else
	#contains $1 "ben" && echo "found ben" #cd /Applications/
	if contains $1 "input"
		then 
		printf "Type three numbers separated by space ' '. -> "
		#IFS="q"
		read NUMBER1 NUMBER2 NUMBER3
		say "You said: $NUMBER1, $NUMBER2, $NUMBER3"
		echo "here"

	elif contains $1 "countdown"
		then
			SECONDS=0
			if [ $# -lt 2 ]
				then
				echo ":::TIPS::: You can also use countdown command like - $ mamu countdown 10 "
				read -p "How many seconds you want to countdown? -> " SECONDS
			else
				SECONDS=$2
			fi
			countDown $SECONDS

	elif contains $1 "findnreplace"
		then
			FILE_NAME=""
			FIND_TEXT=""
			REPLACE_TEXT=""
			IFS="
			"
			if [ $# -lt 4 ]
				then
				echo ":::TIPS::: You can also use findnreplace command like - $ mamu findnreplace /Desktop/myFile.txt 'Old text' 'New text' "
				read -e -p "In which file you want to find a replace text?  -> " FILE_NAME
				read -p "Which text you want to find? -> " FIND_TEXT
				read -p "What text you want to replace with? -> " REPLACE_TEXT
			else
				FILE_NAME=$2
				FIND_TEXT=$3
				REPLACE_TEXT=$4
			fi
			findNreplace $FILE_NAME $FIND_TEXT $REPLACE_TEXT

	elif contains $1 "findtext"
		then
			TEXT_TO_SEARCH=""
			SEARCH_PATH=""
			IFS="
			"
			if [ $# -lt 3 ]
				then
				echo ":::TIPS::: You can also use findtext command like - $ mamu findtext 'love' ~/Desktop/Song-Lyrics"
				read -p "What text you want to search in files?  -> " TEXT_TO_SEARCH
				read -e -p "Which folder/path you want to search? -> " SEARCH_PATH
			else
				TEXT_TO_SEARCH=$2
				SEARCH_PATH=$3
			fi
			findText $TEXT_TO_SEARCH $SEARCH_PATH

	elif contains $1 "ht" || contains $1 "htdocs" || contains $1 "Htdocs"
		then 
		 cd '/Applications/MAMP/htdocs/'
		 echo "there"
	else
		echo "Your utility name is not valid, try a valid one!"

	fi	 
	#contains $1 "ht" || contains $1 "htdocs" || contains $1 "Htdocs" && cd /Applications/MAMP/htdocs/ 
	#contains $1 "pli" && cd /Applications/

fi

