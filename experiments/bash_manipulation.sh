#!/bin/bash

# bash_manipulation.sh - learning bash expansion/manipulation works (bash 4+)

# http://stackoverflow.com/a/5163260
# https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html
# $1, $2, $3, ... are the positional parameters.
# "$@"  is an array-like construct of all positional parameters, {$1,$2,$3,...}
# "$*"  is the IFS expansion of all positional parameters, $1 $2 $3 ....
# $#    is the number of positional parameters.
# $-    current options set for the shell.
# $$    pid of the current shell (not subshell).
# $_    most recent parameter (or abs path of the command to start curr shell)
# $IFS  is the (input) field separator.
# $?    is the most recent foreground pipeline exit status.
# $!    is the PID of the most recent background command.
# $0    is the name of the shell or shell script.

echo "STRING MANIPULATION"
echo "--------------------------------------------------------"
echo "Example 1: Convert entire string to uppercase:"
oldvariable=mississippi
newvariable=${oldvariable^^}
echo "newvariable=\${oldvariable^^} = ${newvariable^^}"
echo "--------------------------------------------------------"

echo "Example 2: Convert only first character to uppercase:"
oldvariable=mississippi
newvariable=${oldvariable^}
echo "newvariable=\${oldvariable^} = ${newvariable^}"
echo "--------------------------------------------------------"

echo "Example 3: Convert entire string to lowercase:"
oldvariable=MISSISSIPPI
newvariable=${oldvariable,,}
echo "newvariable=\${oldvariable,,} = ${newvariable,,}"
echo "--------------------------------------------------------"

echo "Example 4: Convert only first character to lowercase:"
oldvariable=MISSISSIPPI
newvariable=${oldvariable,}
echo "newvariable=\${oldvariable,} = ${newvariable,}"
echo "--------------------------------------------------------"

echo "Example 5: Convert specific characters to uppercase:"
oldvariable=mississippi
newvariable=${oldvariable^^[mi]}
echo "newvariable=\${oldvariable^^[mi]} = ${newvariable}"
echo "--------------------------------------------------------"

echo "Example 6: Convert specific characters to lowercase:"
oldvariable=MISSISSIPPI
newvariable=${oldvariable,,[MI]}
echo "newvariable=\${oldvariable,,[MI]} = ${newvariable}"
echo "--------------------------------------------------------"


echo "FILENAME/PATH MANIPULATION & PARAMETER EXPANSION"
FILE=/usr/share/lib/secrets.tar.gz

echo "Example 1: Path without first directory"
echo "\${FILE#*/} = ${FILE#*/}"
echo "--------------------------------------------------------"

echo "Example 2: Filename with all directories removed"
echo "\${FILE##*/} = ${FILE##*/}"
echo "--------------------------------------------------------"

echo "Example 3: Filename with all directories removed using basename"
echo "\$(basename FILE) = $(basename $FILE)"
echo "--------------------------------------------------------"

echo "Example 4: Only filename extensions"
echo "\${FILE#*.} = ${FILE#*.}"
echo "--------------------------------------------------------"

echo "Example 5: Only the *last* filename extension"
echo "\${FILE##*.} = ${FILE##*.}"
echo "--------------------------------------------------------"

echo "Example 6: Path as directories, no filename"
echo "\${FILE%/*} = ${FILE%/*}"
echo "--------------------------------------------------------"

echo "Example 7: Path as directories, no filename using dirname"
echo "\$(dirname $FILE = $(dirname $FILE)"
echo "--------------------------------------------------------"

echo "Example 8: List only the first directory in the path"
echo "\${FILE%%/*} = ${FILE%%/*}"
echo "--------------------------------------------------------"

echo "Example 9: Path with the last extension removed"
echo "\${FILE%.*} = ${FILE%.*}"
echo "--------------------------------------------------------"

echo "Example 10: Path with all extensions removed"
echo "\${FILE%%.*} = ${FILE%%.*}"
echo "--------------------------------------------------------"

#EOF
