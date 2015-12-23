#!/usr/bin/perl
################################################################################
# Time Package
################################################################################
package Time;

use strict;
use utf8;
use warnings;

sub new {
  my $class = shift;
  my $self  = {};
  my @args = @_;
  my $args = @args;
  if ($args == 0) {
    $self->{'timestamp'} = time;
  } else {
    $self->{'timestamp'} = $args[0];
  }
  ($self->{'second'}, $self->{'minute'}, $self->{'hour'}, $self->{'day'},
    $self->{'month'}, $self->{'year'}, $self->{'weekday'}, $self->{'yearday'},
    $self->{'isdst'}) = localtime($self->{'timestamp'});
  $self->{'year'} += 1900;
  return bless $self, $class;
}

sub toString {
  my $self = shift;
  return $self->{'year'}.'-'.$self->{'month'}.'-'.$self->{'day'}.' '.
    $self->{'hour'}.':'.$self->{'minute'}.':'.$self->{'second'}
}

1;
