#!/bin/bash

# This is a cgi-bin script that accepts remote URL and initiates local import and returns item URL

# Exit code:
#       0   OK
#       1   Invalid remote URL
#       2   Importing failed


exit 0




remote_url="$REMOTE_URL"

if [[ "$remote_url" != http://* ]] && [[ "$remote_url" != https://* ]]; then
    exit 1
fi

url_host="$(cut -d/ -f3 <<< "$remote_url")"
if [[ "$url_host" == 127.* ]] || [[ "$url_host" == '['* ]] || [[ "$url_host" == *.local ]] || [[ "$url_host" == localhost ]]; then
    # HRL host is localhost, or is IPv6, or is within LAN
    exit 1
fi


