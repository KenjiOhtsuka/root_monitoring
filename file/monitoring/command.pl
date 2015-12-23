#!/usr/bin/perl
################################################################################
# Command Package
################################################################################
package Command;

use strict;
use utf8;
use warnings;

sub new {
  my $class = shift;
  my $self  = {};
  my @args  = @_;
  my $args  = @args;
  $self->{'command'} = $args[0];
  $self->{'result'}  = 0;
  return bless $self, $class;
}

sub command {
  my $self = shift;
  return $self->{'command'};
}

sub execute {
  my $self = shift;
  $self->{'last_executed_at'} = Time->new;
  $self->{'output'} = `$self->{'command'}`;
  $self->{'result'} = $?;
  return $self->{'output'};
}

sub result {
  my $self = shift;
  return $self->{'result'};
}

sub output {
  my $self = shift;
  return $self->{'output'};
}

sub lastExecutedAt {
  my $self = shift;
  return $self->{'last_executed_at'};
}

1;
