#!/usr/bin/perl
################################################################################
# Mailer Package
################################################################################
package Mailer;

use strict;
use utf8;
use warnings;
use Digest::MD5;
use Authen::SASL;
use Net::SMTP;

sub new {
  my $class = shift;
  my $self  = {};
  return bless $self, $class;
}

sub to {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'to'} = $args[0];
    return $self;
  }
  return $self->{'to'};
}

sub user {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'user'} = $args[0];
    return $self;
  }
  return $self->{'user'};
}

sub password {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'password'} = $args[0];
    return $self;
  }
  return $self->{'password'};
}

sub from {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'from'} = $args[0];
    return $self;
  }
  return $self->{'from'};
}

sub subject {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'subject'} = $args[0];
    return $self;
  }
  return $self->{'subject'};
}

sub message {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'message'} = $args[0];
    return $self;
  }
  return $self->{'message'};
}

sub host {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'host'} = $args[0];
    return $self;
  }
  return $self->{'host'};
}

sub port {
  my $self = shift;
  my @args = @_;
  my $args = @args;
  if ($args == 1) {
    $self->{'port'} = $args[0];
    return $self;
  }
  return $self->{'port'};
}

sub header {
  my $self = shift;
  my $header = "From: ".($self->{'from'});
  $header .= "\nTo: ".($self->{'to'});
  $header .= "\nSubject: ".($self->{'subject'});
  $header .= "\nMIME-Version: 1.0";
  $header .= "\nContent-Type: text/plain; charset=UTF-8";
  $header .= "\nContent-Transfer-Encoding: Base64\n";
  return $header;
}

sub deliver {
  my $self = shift;
  my $smtp = Net::SMTP->new($self->{'host'}, Port => $self->{'port'}, Hello => 'mail.com');
  $smtp->auth($self->{'user'}, $self->{'password'});
  $smtp->mail($self->{'from'});
  $smtp->to($self->{'to'});
  $smtp->data();
  $smtp->datasend($self->header);
  $smtp->datasend("\n");
  $smtp->datasend($self->{'message'});
  $smtp->quit;
}

1;
