#!/bin/bash

# remove_space.sh - remove spaces of all files of a type in a path

unset a i

if [ $# -ne 1 ]; then
    echo "ERROR: You must supply both a path!"
    echo "  e.g. $0 /home/user/Downloads/"
    exit 1
fi

path=$1

# OLD METHOD
#find $path -type f -print0 | while read -d $'\0' f; do mv -v "$f" "${f// /.}"; done

# iterate through all regular files in $path and rename them
while IFS= read -r -d $'\0' file; do
    mv -v "$file" "${file// /.}"
done < <(find "$path" -type f -print0)

#EOF
