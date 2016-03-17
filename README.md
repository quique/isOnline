isOnline
========

Script for scheduled check of websites availability and mail report. Suited for crontab job.

## Requisites
You should have curl installed.  On Debian-based system you can use something like:
```
sudo apt-get install curl
```

You must install and configure a SMTP server or use a remote one.

For example, use *heirloom-mailx*:
```
sudo apt-get install heirloom-mailx
```
And set up a *~/.mailrc* config file:
```
set smtp-use-starttls
set ssl-verify=ignore
set smtp="$SMTP_SERVER:$SMTP_PORT"
set smtp-auth=login
set smtp-auth-user=$FROM_EMAIL_ADDRESS
set smtp-auth-password=$EMAIL_ACCOUNT_PASSWORD
set from="$FROM_EMAIL_ADDRESS($FRIENDLY_NAME)"
```

## Config
1. Create ```emails.lst``` file and fill it with each email in new line (as in ```emails.lst.example```). leave an empty line in the end.
2. Create ```websites.lst``` file and fill it with each website in a new line (as in ```websites.lst.example```). leave an empty line in the end.

    Note that the websites must include the used protocol (*http://*, for example).

## Add to crontab
Add the following lines to crontab config ($ crontab -e) 

```
THIS_IS_CRON=1
*/30 * * * * /path/to/isOnline/checker.sh
```

in this example crontab will run ```checker.sh``` every 30min.

by [ET][ET].

[ET]: http://etcs.me
