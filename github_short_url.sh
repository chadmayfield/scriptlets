#!/bin/bash

# github_short_url.sh - create a short github url

# HOWTO: https://github.blog/2011-11-10-git-io-github-url-shortener/

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "ERROR: You must supply a github url to shorten"
    exit 1
fi

short=()
url="$1"
vanity="$2"
shortener="https://git.io"

if ! [[ "$url" =~ (github.(com|blog)|githubusercontent.com) ]]; then
    echo "ERROR: Only github.com url's are allowed!"
    exit 1
else
    if [ ! -z ${vanity+x} ]; then
        # vanity url was requestedi
        # mapfile, only for bash v4.0+
#        mapfile -t short < <( curl -i "$shortener" -F "url=${url}" -F "code=${vanity}" | grep -E "(Status|Location): " )

        # work around for ancient version of bash on macOS
        while IFS= read -r line; do
            short+=( "$line" )
        done < <( curl -si "$shortener" -F "url=${url}" -F "code=${vanity}" | grep -E "(Status|Location): " )

    else
        # mapfile, only for bash v4.0+
#        mapfile -t short < <( curl -i "$shortener" -F "url=${url}" | grep -E "(Status|Location): " )

        # work around for ancient version of bash on macOS
        while IFS= read -r line; do
            short+=( "$line" )
        done < <( curl -si "$shortener" -F "url=${url}" | grep -E "(Status|Location): " )
    fi

    if [[ ${short[0]} =~ "201" ]]; then
        echo "Link created: $(echo ${short[1]} | awk '{print $2}')"
    else
        echo "ERROR: Link creation failed! Code $(echo ${short[0]} | sed 's|Status: ||g')"
    fi
fi

#EOF
