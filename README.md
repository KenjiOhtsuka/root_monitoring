# root_monitoring

This is monitoring files written in Perl.
I use them on Amazon Linux.

It checks server resource and daemon status and sends e-mail.

# Usage
## Set up
1. update `monitoring/config.pl` to adapt to your server.
1. `sudo file/root_setup.sh development ap` for development application server  
`sudo file/root_setup.sh development mail` for development mail server  
`sudo file/root_setup.sh production ap` for production application server  
`sudo file/root_setup.sh production mail` for production mail server  
You can execute the above command everywhere.  
Then, required Perl files are copied to `root` directory.

# Feature
This checks resource and service status.  
`root_setup.sh` set the crontab to execute `resource_check.pl` every 3 minutes and `service_check.pl` every day.

## for Application Server
* Service Check: check nginx status, and when they're down, reboot them and send mail.

## for Mail Server
* Service Check: check saslauthd and postfix status, and when they're down, reboot them and send mail.

## for Every Server
* Resource Check: send the results of `df -h` and `free -m` as e-mail.
