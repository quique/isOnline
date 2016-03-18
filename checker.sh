#!/bin/bash
# Website status checker. by ET (etcs.me)

#WORKSPACE=/scripts/isOnline
WORKSPACE=`dirname "$(readlink -f "$0")"`
# List of websites.  Each website in new line.
LISTFILE=$WORKSPACE/websites.lst
# Addresses to send mail in case of failure, one per line.
EMAILLISTFILE=$WORKSPACE/emails.lst
# Temporary dirs
WARNINGS=$WORKSPACE/warnings
ERRORS=$WORKSPACE/errors
# Word to watch, known to be included in the page.
# It is not required to be visible, it can be in a HTML comment.
CANARY=Directorio

# `Quiet` is true when in crontab; show output when it's run manually from shell.
# Set THIS_IS_CRON=1 in the beginning of your crontab -e.
# Otherwise you will get the output to your email every time.
if [ -n "$THIS_IS_CRON" ]; then QUIET=true; else QUIET=false; fi

function test {
    #response=$(curl --write-out %{http_code} --silent --output /dev/null $1)
    #filename=$( echo $1 | cut -f1 -d"/" )
    response=$(curl --silent -L $1)
    filename=$( echo $1 | tr / _ )
    if [ "$QUIET" = false ]; then echo -n "$p "; fi

    #if [ $response -eq 200 ] ; then
    if echo $response | grep $CANARY > /dev/null; then
        # website working
        if [ "$QUIET" = false ]; then echo -e "\e[32m[ok]\e[0m"; fi
        # Remove temporary files if they exist.
        if [ -f $WARNINGS/$filename ]; then rm -f $WARNINGS/$filename; fi
        if [ -f $ERRORS/$filename ]; then rm -f $ERRORS/$filename; fi
    else
        # website down
        if [ ! -f $WARNINGS/$filename ]; then
            # Down for the first time.  Just show a warning.
            if [ "$QUIET" = false ]; then echo -e "\e[33m[down]\e[0m"; fi
            echo > $WARNINGS/$filename
        else
            # It keeps being down. Show an error.
            if [ "$QUIET" = false ]; then echo -e "\e[31m[DOWN]\e[0m"; fi
            if [ ! -f $ERRORS/$filename ]; then
                # 2nd time down.  Send e-mail.
                while read e; do
                    echo "$p WEBSITE DOWN" | mailx -s "$1 WEBSITE DOWN" $e
                done < $EMAILLISTFILE
                echo > $ERRORS/$filename
            fi
        fi
    fi
}

# main loop
while read p; do
    test $p
done < $LISTFILE
