package Tk::ForDummies::Graph::Utils;

#==================================================================
# Author    : Djibril Ousmanou
# Copyright : 2009
# Update    : 30/03/2009
# AIM       : Private functions and public shared methods
#             between Tk::ForDummies::Graph modules
#==================================================================
use warnings;
use strict;
use Carp;

use vars qw($VERSION);
$VERSION = '1.00';

use Exporter;

my @ModuleToExport = qw (
  _MaxArray   _MinArray   _isANumber _roundValue
  zoom        zoomx      zoomy      clearchart
);

our @ISA         = qw(Exporter);
our @EXPORT_OK   = @ModuleToExport;
our %EXPORT_TAGS = ( DUMMIES => \@ModuleToExport );

sub _MaxArray {
  my ($RefNumber) = @_;
  my $max;

  for my $chiffre ( @{$RefNumber} ) {
    next unless ( defined $chiffre and _isANumber($chiffre) );
    $max = _max( $max, $chiffre );
  }

  return $max;
}

sub _MinArray {
  my ($RefNumber) = @_;
  my $min;

  for my $chiffre ( @{$RefNumber} ) {
    next unless ( defined $chiffre and _isANumber($chiffre) );

    $min = _min( $min, $chiffre );
  }

  return $min;
}

sub _max {
  my ( $a, $b ) = @_;
  if ( not defined $a ) { return $b; }
  if ( not defined $b ) { return $a; }
  if ( not defined $a and not defined $b ) { return; }

  if   ( $a >= $b ) { return $a; }
  else              { return $b; }

  return;
}

sub _min {
  my ( $a, $b ) = @_;
  if ( not defined $a ) { return $b; }
  if ( not defined $b ) { return $a; }
  if ( not defined $a and not defined $b ) { return; }

  if   ( $a <= $b ) { return $a; }
  else              { return $b; }

  return;
}

sub _roundValue {
  my ($Value) = @_;
  return sprintf( "%.2g", $Value );
}

# Test if value is a real number
sub _isANumber {
  my ($Value) = @_;

  if ( $Value
    =~ /^(?:(?i)(?:[+-]?)(?:(?=[0123456789]|[.])(?:[0123456789]*)(?:(?:[.])(?:[0123456789]{0,}))?)(?:(?:[E])(?:(?:[+-]?)(?:[0123456789]+))|))$/
    )
  {
    return 1;
  }

  return;
}

sub zoom {
  my ( $CompositeWidget, $Zoom ) = @_;

  my ( $NewWidth, $NewHeight ) = $CompositeWidget->_ZoomCalcul( $Zoom, $Zoom );
  $CompositeWidget->configure( -width => $NewWidth, -height => $NewHeight );
  $CompositeWidget->toplevel->geometry("");

  return 1;
}

sub zoomx {
  my ( $CompositeWidget, $Zoom ) = @_;

  my ( $NewWidth, $NewHeight ) = $CompositeWidget->_ZoomCalcul( $Zoom, undef );
  $CompositeWidget->configure( -width => $NewWidth );
  $CompositeWidget->toplevel->geometry("");

  return 1;
}

sub zoomy {
  my ( $CompositeWidget, $Zoom ) = @_;

  my ( $NewWidth, $NewHeight ) = $CompositeWidget->_ZoomCalcul( undef, $Zoom );
  $CompositeWidget->configure( -height => $NewHeight );
  $CompositeWidget->toplevel->geometry("");

  return 1;
}

# Clear the Canvas Widget
sub clearchart {
  my ($CompositeWidget) = @_;

  $CompositeWidget->update;
  $CompositeWidget->delete('all');

  return;
}

1;

__END__

=head1 NAME

Tk::ForDummies::Graph::Utils - Internal utilities used by Tk::ForDummies::Graph modules

=head1 SYNOPSIS

none

=head1 DESCRIPTION

no public subroutines

=head1 AUTHOR

Djibril Ousmanou, C<< <djibrilo at yahoo.fr> >>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Djibril Ousmanou, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=head1 SEE ALSO

L<Tk::ForDummies::Graph>

=cut
