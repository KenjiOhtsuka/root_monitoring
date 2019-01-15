#!/usr/bin/perl
################################################################################
# Slack Package
################################################################################
package SlackMessage

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;

my $url = Config->;

sub new {
  my $self = shift;
  my $self = {};
  return bless $self, $class
}

sub channel {
  my $self = shift;
  if (@_) {
    $self->{channel} = shift;
    return $self;
  }
  return $self->{channel};
}

sub userName {
  $self = shift;
  if (@_) {
    $self->{user_name} = shift;
    return $self;
  }
  return $self->{user_name};
}

sub text {
  $self = shift;
  if (@_) {
    $self->{text} = shift;
    return $self;
  }
  return $self->{text};
}

1;
