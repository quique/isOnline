#!/bin/bash
# Website status checker. by ET (etcs.me)

#WORKSPACE=/scripts/isOnline
WORKSPACE=`dirname "$(readlink -f "$0")"`
# list of websites. each website in new line. Leave an empty line in the end.
LISTFILE=$WORKSPACE/websites.lst
# Send mail in case of failure to. Leave an empty line in the end.
EMAILLISTFILE=$WORKSPACE/emails.lst
# Temporary dir
TEMPDIR=$WORKSPACE/cache
# Word to watch, known to be included in the page.
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
    if [ "$QUIET" = false ] ; then echo -n "$p "; fi

    #if [ $response -eq 200 ] ; then
    if echo $response | grep $CANARY > /dev/null; then
        # website working
        if [ "$QUIET" = false ] ; then
            echo -e "\e[32m[ok]\e[0m"
        fi
        # Remove temporary file if it exists.
        if [ -f $TEMPDIR/$filename ]; then rm -f $TEMPDIR/$filename; fi
    else
        # website down
        if [ ! -f $TEMPDIR/$filename ]; then
            # Down for the first time.  Just show a warning.
            if [ "$QUIET" = false ] ; then echo -e "\e[33m[down]\e[0m"; fi
            echo > $TEMPDIR/$filename
        else
            # It keeps being down. Show an error and send mail.
            if [ "$QUIET" = false ] ; then echo -e "\e[31m[DOWN]\e[0m"; fi
            while read e; do
                : # Uncomment one of the mail commands to be notified via email
                # using mailx command
                #echo "$p WEBSITE DOWN" | mailx -s "$1 WEBSITE DOWN ( $response )" $e
                # using mail command
                #mail -s "$p WEBSITE DOWN" "$EMAIL"
            done < $EMAILLISTFILE
        fi
    fi
}

# main loop
while read p; do
    test $p
done < $LISTFILE
