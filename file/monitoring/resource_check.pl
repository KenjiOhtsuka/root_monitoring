#!/usr/bin/perl

use File::Basename;
use File::Spec;

my $dirpath = File::Spec->rel2abs(dirname(__FILE__));
require $dirpath.'/config.pl';
require $dirpath.'/mailer.pl';
require $dirpath.'/time.pl';
require $dirpath.'/command.pl';

our $mailConfig = Config->new($ARGV[0])->get->{'mail'};

################################################################################
# Main Process
################################################################################
package Main;

use strict;
use utf8;
use warnings;

# check resources

my $dfCommand = Command->new('df -h');
my $freeCommand = Command->new('free -m');

my $time = Time->new;

$dfCommand->execute;
$freeCommand->execute;

my $hostname = Command->new('hostname')->execute;
chomp($hostname);
my $subject = 'Resource Report';
my $message = $hostname.' '.($time->toString);
$message .= "\n\nresult of : ".($dfCommand->command);
$message .= "\n".$dfCommand->output;
$message .= "\n\nresult of : ".($freeCommand->command);
$message .= "\n".$freeCommand->output;
if ($dfCommand->result != 0 || $freeCommand->result != 0) {
  $message .= "\n\nError has occurred, on executing commands.";
}

# send mail report
my $mailer = Mailer->new;
$mailer->user($mailConfig->{'user'});
$mailer->password($mailConfig->{'password'});
$mailer->from($mailConfig->{'from'});
$mailer->to($mailConfig->{'to'});
$mailer->subject($subject);
$mailer->message($message);
$mailer->host($mailConfig->{'host'});
$mailer->port($mailConfig->{'port'});
$mailer->deliver;

exit($dfCommand->result || $dfCommand);

