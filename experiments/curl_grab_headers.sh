#!/bin/bash

# curl_grab_headers.sh - grab specific headers, was to experiment to get http
#                        status codes in bash for a script at one timee

var=( content_type filename_effective ftp_entry_path http_code http_connect local_ip local_port num_connects num_redirects redirect_url remote_ip remote_port size_download size_header time_appconnect time_connect time_namelookup time_pretransfer time_redirect time_starttransfer time_total url_effective size_request size_upload speed_download speed_upload ssl_verify_result time_appconnect time_connect time_namelookup time_pretransfer time_redirect time_starttransfer time_total url_effective )

# according to the man page (https://curl.haxx.se/docs/manpage.html) only one
# variable can be used at a time; "If this option is used several times, the 
# last one will be used." which is inefficent, but this is just a test
for i in "${var[@]}"
do
    resp=$(curl -Iso /dev/null -w "%{$i}" https://www.google.com/robots.txt)
    printf "%-20s\t%s\n" "$i" "$resp"
    #sleep 1
done

#EOF
