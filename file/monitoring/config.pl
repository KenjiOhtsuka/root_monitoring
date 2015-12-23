#!/usr/bin/perl
################################################################################
# Config Package
################################################################################
package Config;

use strict;
use utf8;
use warnings;

my $config = {
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
  my $environment = $args[0];
  if ($environment eq 'development') {
    $self->{'environment'} = $environment;
  } elsif ($environment eq 'production') {
    $self->{'environment'} = $environment;
  }
  return bless $self, $class;
}

sub get {
  my $self = shift;
  return $config->{$self->{'environment'}};
}

1;
