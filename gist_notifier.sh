#!/bin/bash

#GITHUB_USERNAME=zebrastack
PREREQ_PACKAGES="jq base64"

#Use above GITHUB_USERNAME variable if its already set if not get variable from the first command line argument
if test ".$GITHUB_USERNAME." = ".."
then
    if test -z $1
    then

        echo "Usage: $0 <username>"
        echo "Example: $0 zebrastack"

        exit
    else
        GITHUB_USERNAME=$1
    fi
fi

#Check for prereq packages
for prereq in `echo $PREREQ_PACKAGES`
do
    which $prereq 1>/dev/null 2>&1
    if test $? -ne 0
    then
        echo "$prereq package could not find on the system, please install it first and then rerun the program"
        exit 5
    fi
done

GITHUB_BASE_URL=https://api.github.com/users/$GITHUB_USERNAME/gists
    
curl -s $GITHUB_BASE_URL | jq --raw-output '.[] | [.id,.created_at,.html_url,.description] | @base64' 2>/dev/null 1>/tmp/gist_notifier$$
return_val=$?

#Check Connection to GitHub Api, also its very easy to hit the github rate limit
if test $return_val -ne 0
then
    echo 
    echo "Problem accesing Github API Server \"$GITHUB_BASE_URL\", to solve the problem:"
    echo "1) Check your connection to: https://api.github.com"
    echo "2) If you use api too frequently then maybe you could hit to the Github rate limit, details: https://developer.github.com/v3/#rate-limiting"
    echo
    echo "Please check the above conditions and then try again"
    echo 
    
    exit
fi

touch /tmp/gist_notifier.last

#Check if there is any change on cache file till we last run
diff /tmp/gist_notifier$$ /tmp/gist_notifier.last 1>/dev/null 2>&1
return_val=$?

if test $return_val -eq 1 
then

    header_control=1
    while read gist
    do
        if test `grep -c "$gist" /tmp/gist_notifier.last` -eq 0
        then
            id=`echo "$gist" | base64 --decode | jq -r '.[0]'`
            created_at=`echo "$gist"|base64 --decode | jq -r '.[1]'`
            html_url=`echo "$gist"|base64 --decode | jq -r '.[2]'`
            description=`echo "$gist"|base64 --decode | jq -r '.[3]'`
     
            if test $header_control -eq 1
            then 
                echo "New Github Gist Detected For Account: \"$GITHUB_USERNAME\", its details are below:"
                echo

            fi
            echo "Description: $description"
            echo "Creation Time: $created_at"
            echo "Html Url: $html_url"
            echo
            ((++header_control))
    
            #Save id to temp control file to display new gists on next program run
            echo $gist >> /tmp/gist_notifier.last
        fi
    done < /tmp/gist_notifier$$
fi
