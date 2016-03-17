#!/bin/bash
# Website status checker. by ET (etcs.me)

#WORKSPACE=/scripts/isOnline
WORKSPACE=.
# list of websites. each website in new line. leave an empty line in the end.
LISTFILE=$WORKSPACE/websites.lst
# Send mail in case of failure to. leave an empty line in the end.
EMAILLISTFILE=$WORKSPACE/emails.lst
# Temporary dir
TEMPDIR=$WORKSPACE/cache
# Word to watch, known to be included in the page.
CANARY=Directorio

# `Quiet` is true when in crontab; show output when it's run manually from shell.
# Set THIS_IS_CRON=1 in the beginning of your crontab -e.
# else you will get the output to your email every time
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
        # remove .temp file if exist 
        if [ -f $TEMPDIR/$filename ]; then rm -f $TEMPDIR/$filename; fi
    else
        # website down
        if [ "$QUIET" = false ] ; then echo -e "\e[31m[DOWN]\e[0m"; fi
        if [ ! -f $TEMPDIR/$filename ]; then
            while read e; do
                : # Uncomment one of the mail commands to be notified via email
                # using mailx command
                #echo "$p WEBSITE DOWN" | mailx -s "$1 WEBSITE DOWN ( $response )" $e
                # using mail command
                #mail -s "$p WEBSITE DOWN" "$EMAIL"
            done < $EMAILLISTFILE
            echo > $TEMPDIR/$filename
        fi
    fi
}

# main loop
while read p; do
    test $p
done < $LISTFILE
