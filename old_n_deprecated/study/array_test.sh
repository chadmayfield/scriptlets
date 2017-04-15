#!/bin/bash

# array_test.sh - NOT MY CODE, can't remember where I got this, but it's a
#                 good reminder of bash arrays

array=( $( find . -name *.txt ) )

echo "Array size: ${#array[*]}"

echo "Array items:"
for item in ${array[*]}
do
    printf "   %s\n" $item
done

echo "Array indexes:"
for index in ${!array[*]}
do
    printf "   %d\n" $index
done

echo "Array items and indexes:"
for index in ${!array[*]}
do
    printf "%4d: %s\n" $index ${array[$index]}
done
