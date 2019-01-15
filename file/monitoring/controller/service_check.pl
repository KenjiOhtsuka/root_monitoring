#!/usr/bin/perl
# This script start server services if they are down.
# Server services to be checked are the following.
#   - sshd
#   - nginx (optional)
#   - saslauthd (optional)
#   - postfix (optional)
#
# Parameter
#   environment identifier : development_remote or production
#   service list           : service list connected by comma
# Usage
#   service_check.pl development_remote nginx,saslauthd,postfix

use File::Basename;
use File::Spec;

my $dirpath = File::Spec->rel2abs(dirname(__FILE__));
require $dirpath.'/config.pl';
require $dirpath.'/mailer.pl';
require $dirpath.'/time.pl';
require $dirpath.'/command.pl';

our $mailConfig = Config->new($ARGV[0])->get->{'mail'};
our @serviceList = split(/,/, $ARGV[1]);

################################################################################
# Process Package
################################################################################
package Process;

use strict;
use utf8;
use warnings;

sub new {
  my $class = shift;
  my $self  = {};
  return bless $self, $class;
}

sub attr {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    return $self->{$args[0]};
  }
  if ($args == 2) {
    return $self->{$args[0]} = $args[1];
  }
}

################################################################################
# Service Package
################################################################################
package Service;

use strict;
use utf8;
use warnings;

sub new {
  my $class = shift;
  my $self  = {};
  my @args  = @_;
  $self->{'name'}         = $args[0];
  $self->{'process_args'} = $args[1];
  $self->{'command'}      = Command->new($args[2]);
  $self->{'ppid'}         = 1;
  return bless $self, $class;
}

sub name {
  my $self = shift;
  return $self->{'name'};
}

sub command {
  my $self = shift;
  if ($self->{'command'}) {
    return $self->{'command'};
  }
  $self->{'command'} = Command->new("/sbin/service ".($self->{'name'})." start");
  return $self->{'command'};
}

sub processArgs {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'process_args'} = $args[0];
    return $self;
  }
  return $self->{'process_args'};
}

sub ppid {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'ppid'} = $args[0];
    return $self;
  }
  return $self->{'ppid'};
}
################################################################################
# Main Process
################################################################################
package Main;

use strict;
use utf8;
use warnings;

# check processes

my $ps =`ps -eo user,pid,ppid,%cpu,%mem,comm,args`;
my @psList = split(/\n+/, $ps);

my @processes = ();
my @serviceStatuses = ();
push(@serviceStatuses, {
  'status' => 0,
  'service' => Service->new(
    'Sshd',
    '/usr/sbin/sshd',
    '/sbin/service sshd start'
  )
});
if (grep {$_ eq 'nginx'} @serviceList) {
  push(@serviceStatuses, {
    'status' => 0,
    'service' => Service->new(
      'Nginx',
      'nginx: master process /opt/nginx/sbin/nginx',
      '/opt/nginx/sbin/nginx'
    )
  });
}
if (grep {$_ eq 'postfix'} @serviceList) {
  push(@serviceStatuses, {
    'status' => 0,
    'service' => Service->new(
      'Postfix',
      '/usr/libexec/postfix/master',
      '/sbin/service postfix start'
    )
  });
}
if (grep {$_ eq 'saslauthd'} @serviceList) {
  push(@serviceStatuses, {
    'status' => 0,
    'service' => Service->new(
      'SaslAuthd',
      '/usr/sbin/saslauthd -m /var/run/saslauthd -a pam',
      '/sbin/service saslauthd start'
    )
  });
}

# process for each process line
foreach my $psItem(@psList) {
  $psItem =~ /^([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+(.+)$/;
  my $process = Process->new;
  $process->attr('user', $1);
  $process->attr('pid',  $2);
  $process->attr('ppid', $3);
  $process->attr('cpu',  $4);
  $process->attr('mem',  $5);
  $process->attr('comm', $6);
  $process->attr('args', $7);
  push(@processes, $process);
}

foreach my $process(@processes) {
  foreach my $serviceStatus(@serviceStatuses) {
    if ($serviceStatus->{'status'} == 0 &&
      $serviceStatus->{'service'}->processArgs eq $process->attr('args')) {
      if ($process->attr('ppid') == $serviceStatus->{'service'}->ppid) {
        $serviceStatus->{'status'} = 1;
      }
    }
  }
}

# restart stopping services

my $toSendMail = 0;
my $hasError   = 0;
foreach my $serviceStatus(@serviceStatuses) {
  if ($serviceStatus->{'status'} == 0) {
    $toSendMail = 1;
    $serviceStatus->{'service'}->command->execute;
    $hasError = ($hasError == 0 && $serviceStatus->{'service'}->command->result == 0 ? 0 : 1);
  }
}

if ($toSendMail == 1) {
  my $hostname = Command->new('hostname')->execute;
  chomp($hostname);
  my $subject = '['.($hasError == 0 ? 'Success' : 'Fail').'] Restart Services';
  my $message = "I recommend you to check server ".$hostname.".";

  foreach my $serviceStatus(@serviceStatuses) {
    if ($serviceStatus->{'status'} == 0) {
      $message .= "\n\n".$serviceStatus->{'service'}->command->lastExecutedAt->toString.
        " : ".$serviceStatus->{'service'}->name." : ".
        ($serviceStatus->{'service'}->command->result == 0 ? "Success" : "Fail");
      $message .= "\n\n== Output ==\n".$serviceStatus->{'service'}->command->output;
    }
  }

  sleep(3);

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
}

exit($hasError);
