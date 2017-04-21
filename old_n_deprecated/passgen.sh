#!/bin/bash

# date: 04/19/2009
# author: Chad Mayfield (http://www.chadmayfield.com/)
# license: gpl v3 (http://www.gnu.org/licenses/gpl-3.0.txt)

#+-- Check to see if there are any arguments passed to the function
if [ ! $1 ]; then
	echo "You must supply a password length, or use --help for usage."
	exit 1
fi

#+-- Check to see there was one argument passed to the function
if [ "$1" = "--help" ]; then
    echo "Usage:\t "
elif [ $# -gt 2 ]; then
    echo "Error! Too many arguments entered. Please try again or use --help for usage."
elif [ $# -eq 1 ]; then
    #+-- Check to see if that argument was numeric
    echo $1 | egrep "[^0-9]+" > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        echo "Error! You number was not entered.  Please try again or use --help for usage."
    else
        if [ $1 -gt 8 ]; then
            #+-- Now check to see that the number is between 8 and 50
            if [ $1 -lt 56 ]; then
                passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c${1}`
                echo "Your random password is: ${passwd}"
            else
                echo "Error! Password length must be less than 55!  Please try again or use --help for usage."
            fi
        else
            #+-- If it was not numeric notify the user.
            echo "Error! Password length must be less than 8!  Please try again or use --help for usage."
        fi
    fi
#+-- Check to see if there was two arguments passed to the function
elif [ $# -eq 2 ]; then
    #+-- Check to see if that argument was numeric
    echo $1 | egrep "[^0-9]+" > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        echo "Error! You did not enter a number try again or use --help for usage."
    else
        if [ "$2" = "simple" ]; then
            passwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c${1}`
            echo "Your password is: ${passwd}"
        elif [ "$2" = "complex" ]; then
            passwd=`< /dev/urandom tr -dc A-Za-z0-9_\$\%\?\!\"\/\(\)- | head -c${1}`
            echo "Your password is: ${passwd}"
        else
            echo "Error! Second arguement is invalid, use --help for usage."
        fi
    fi
else
    echo "Error! Invalid arguements entered, please try again, or use --help for usage."
fi
