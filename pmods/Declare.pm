#!/usr/bin/perl -w
use strict;
use warnings;

package Declare;

sub new {
  my $create = shift;
  my $column_property = {
     _cellc      => shift,
     _charlen    => shift,
     _isnum      => shift,
     _isint      => shift,
     _isunsigned => shift,
     _numlen     => shift,
     _denlen     => shift,
  };
  bless $column_property,$create;
  return $column_property;
}
sub set_denlen       { my ($cp,$msg) = @_;
  $cp->{_denlen}     = $msg if defined $msg;
  return $cp->{_denlen};
} sub get_denlen     { my ($cp) = @_;
  return $cp->{_denlen};
}
sub set_numlen       { my ($cp,$msg) = @_;
  $cp->{_numlen}     = $msg if defined $msg;
  return $cp->{_numlen};
} sub get_numlen     { my ($cp) = @_;
  return $cp->{_numlen};
}
sub set_isunsigned   { my ($cp,$msg) = @_;
  $cp->{_isunsigned} = $msg if defined $msg;
  return $cp->{_isunsigned};
} sub get_isunsigned { my ($cp) = @_;
  return $cp->{_isunsigned};
}
sub set_isint        { my ($cp,$msg) = @_;
  $cp->{_isint}      = $msg if defined $msg;
  return $cp->{_isint};
} sub get_isint      { my ($cp) = @_;
  return $cp->{_isint};
}
sub set_isnum        { my ($cp,$msg) = @_;
  $cp->{_isnum}      = $msg if defined($msg);
  return $cp->{_isnum};
} sub get_isnum      { my ($cp) = @_;
  return $cp->{_isnum};
}
sub set_charlen      { my ($cp,$msg) = @_;
  $cp->{_charlen}    = $msg if defined($msg);
  return $cp->{_charlen};
} sub get_charlen    { my ($cp) = @_;
  return $cp->{_charlen};
}
sub set_istext       { my ($cp,$msg) = @_;
  $cp->{_istext}     = $msg if defined($msg);
  return $cp->{_istext};
} sub get_istext     { my ($cp) = @_;
  return $cp->{_istext};
}
sub set_cellc        { my ($cp,$msg) = @_;
  $cp->{_cellc}      = $msg if defined($msg);
  return $cp->{_cellc};
} sub get_cellc      { my ($cp) = @_;
  return $cp->{_cellc};
}
sub set_msg {
}
1;
