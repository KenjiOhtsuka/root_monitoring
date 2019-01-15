#!/usr/bin/perl
################################################################################
# Config Package
################################################################################
package Config;

use strict;
use utf8;
use warnings;

my $config = {
  'global' => {
    'services' => [
      # name : label
      # process args : ps -eo args
      # command : ps -eo comm
      {
        'name'         => 'Sshd',
        'process_args' => '/usr/sbin/sshd',
        'command'      => '/sbin/service sshd start'
      },
      {
        'name'         => 'Nginx',
        'process_args' =>
          'nginx: master process /opt/nginx/sbin/nginx',
        'command'      => '/opt/nginx/sbin/nginx'
      },
      {
        'name'         => 'Sshd',
        'process_args' => '',
        'command'      => ''
      },
      {
        'name'         => 'Postfix',
        'process_args' => '/usr/libexec/postfix/master',
        'command'      => '/sbin/service/postfix start'
      },
      {
        'name'         => 'SaslAuthd',
        'process_args' =>
          '/usr/sbin/saslauthd -m /var/run/saslauthd -a pam',
        'command'      => '/sbin/service saslauthd start'
      }
    ]
  },
  'development' => {
    'mail' => {
      'host'     => '123.456.789.012',
      'port'     => 587,
      'from'     => 'example-from@mail.com',
      'to'       => 'example-to@mail.com',
      'user'     => 'development_sender',
      'password' => '1234567890',
    }
  },
  'production' => {
    'mail' => {
      'host'     => '123.456.789.012',
      'port'     => 587,
      'from'     => 'example-from@mail.com',
      'to'       => 'example-to@mail.com',
      'user'     => 'production_sender',
      'password' => '1234567890',
    }
  }
};

sub new {
  my $class = shift;
  my $self  = {};
  my @args  = @_;
  if (@_) {
    $self->{'environment'} = $args[0];
  }
  return bless $self, $class;
}

sub get {
  my $self = shift;
  my $tmp = $config;
  foreach my $i (@_) {
    $tmp = $tmp->{$i};
  }
  if (exists($self->{'environment'})) {
    my $envVal = $config;
    foreach my $i (@_) {
      if (exists($envVal->{$i})) {
        $envVal = $envVal->{$i};
      } else {
        break;
      }
    }
    $tmp = $envVal
  }
  return $tmp;
}

1;
