package Tk::ForDummies::Graph::Utils;

#==================================================================
# Author    : Djibril Ousmanou
# Copyright : 2009
# Update    : 16/07/2009 21:15:30
# AIM       : Private functions and public shared methods
#             between Tk::ForDummies::Graph modules
#==================================================================
use warnings;
use strict;
use Carp;

use vars qw($VERSION);
$VERSION = '1.03';

use Exporter;

my @ModuleToExport = qw (
  _MaxArray   _MinArray   _isANumber _roundValue
  zoom        zoomx      zoomy       clearchart
  _Quantile   _moy       _NonOutlier _GetControlPoints
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

sub _moy {
  my ($RefValues) = @_;

  my $TotalValues = scalar( @{$RefValues} );

  return if ( $TotalValues == 0 );

  my $moy = 0;
  for my $value ( @{$RefValues} ) {
    $moy += $value;
  }

  $moy = ( $moy / $TotalValues );

  return $moy;
}

sub _isPair {
  my ($number) = @_;

  unless ( defined $number and $number =~ m{^\d+$} ) {
    croak "$number not an integer\n";
  }

  if ( $number % 2 == 0 ) {
    return 1;
  }

  return;
}

sub _Median {
  my ($RefValues) = @_;

  # sort data
  my @values = sort { $a <=> $b } @{$RefValues};
  my $TotalValues = scalar(@values);
  my $median;

  # Number of data pair
  if ( _isPair($TotalValues) ) {

    # 2 values for center
    my $Value1 = $values[ $TotalValues / 2 ];
    my $Value2 = $values[ ( $TotalValues - 2 ) / 2 ];
    $median = ( $Value1 + $Value2 ) / 2;
  }

  # Number of data impair
  else {
    $median = $values[ ( $TotalValues - 1 ) / 2 ];
  }

  return $median;
}

# The Quantile is calculated as in Excel  
# In R language it is the equivalent of quantile type 7
sub _Quantile {
  my ($RefValues) = @_;

  # sort data
  my @values = sort { $a <=> $b } @{$RefValues};
  my $TotalValues = scalar(@values);
  my ( $Quantile1, $Quantile2, $Quantile3 );
  my ( @BottomTab, @UpTab );

  my $IndexCenter = ( $TotalValues / 2 ) - 1;

  # Number of data pair
  if ( _isPair($TotalValues) ) {
    @BottomTab = @values[ 0 .. $IndexCenter ];
    @UpTab     = @values[ $IndexCenter + 1 .. $TotalValues - 1 ];
  }

  # Number of data impair
  else {
    $IndexCenter = ( $TotalValues - 1 ) / 2;
    @BottomTab   = @values[ 0 .. $IndexCenter  ];
    @UpTab       = @values[ $IndexCenter  .. $TotalValues - 1 ];
  }

  $Quantile1 = _Median( \@BottomTab );
  $Quantile2 = _Median( \@values );
  $Quantile3 = _Median( \@UpTab );

  return ( $Quantile1, $Quantile2, $Quantile3 );
}

sub _NonOutlier {
  my ( $RefValues, $Q1, $Q3 ) = @_;

  # interquartile range,
  my $IQR = $Q3 - $Q1;

  # low and up boundaries
  my $LowBoundary = $Q1 - ( 1.5 * $IQR );
  my $UpBoundary  = $Q3 + ( 1.5 * $IQR );

  # largest non-outlier and smallest non-outlier
  my ( $LnonOutlier, $SnonOutlier );
  for my $Value ( sort { $a <=> $b } @{$RefValues} ) {
    if ( $Value > $LowBoundary ) {
      $SnonOutlier = $Value;
      last;
    }
  }

  for my $Value ( sort { $b <=> $a } @{$RefValues} ) {
    if ( $Value < $UpBoundary ) {
      $LnonOutlier = $Value;
      last;
    }
  }

  return ( $SnonOutlier, $LnonOutlier );
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

sub _GetControlPoints {
  my ( $CompositeWidget, $RefArray ) = @_;

  my $NbrElt = scalar @{$RefArray};

  unless ( $NbrElt > 4 ) {
    return $RefArray;
  }

  # First element
  my @AllControlPoints = ( $RefArray->[0], $RefArray->[1] );

  for ( my $i = 0; $i <= $NbrElt; $i = $i + 2 ) {
    my @PointA = ( $RefArray->[$i], $RefArray->[ $i + 1 ] );
    my @PointB = ( $RefArray->[ $i + 2 ], $RefArray->[ $i + 3 ] );
    my @PointC = ( $RefArray->[ $i + 4 ], $RefArray->[ $i + 5 ] );

    last unless ( defined $RefArray->[ $i + 5 ] );

    # Equation between PointA and PointC
    # Coef = (yc -ya) / (xc -xa)
    # D1 : Y = Coef * X + (ya - (Coef * xa))
    my $coef = ( $PointC[1] - $PointA[1] ) / ( $PointC[0] - $PointA[0] );

    # Equation for D2 ligne paralelle to [AC] with PointB
    # D2 : Y = (Coef * X) + yb - (coef * xb)
    # The 2 control points
    my $D2line = sub {
      my ($x) = @_;

      my $y = ( $coef * $x ) + $PointB[1] - ( $coef * $PointB[0] );
      return $y;
    };

    # distance
    my $distance = 0.95;

    # xc1 = ( (xb - xa ) / 2 ) + xa
    # yc1 = via D2
    my @ControlPoint1;
    $ControlPoint1[0] = ( $distance * ( $PointB[0] - $PointA[0] ) ) + $PointA[0];
    $ControlPoint1[1] = $D2line->( $ControlPoint1[0] );
    push( @AllControlPoints, ( $ControlPoint1[0], $ControlPoint1[1] ) );

    # points
    push( @AllControlPoints, ( $PointB[0], $PointB[1] ) );

    # xc2 = ( (xc - xb ) / 2 ) + xb
    # yc2 = via D2
    my @ControlPoint2;
    $ControlPoint2[0]
      = ( ( 1 - $distance ) * ( $PointC[0] - $PointB[0] ) ) + $PointB[0];
    $ControlPoint2[1] = $D2line->( $ControlPoint2[0] );

    push( @AllControlPoints, ( $ControlPoint2[0], $ControlPoint2[1] ) );
  }

  push( @AllControlPoints,
    $RefArray->[ $NbrElt - 2 ],
    $RefArray->[ $NbrElt - 1 ] );

  return \@AllControlPoints;
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

Djibril Ousmanou, C<< <djibel at cpan.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Djibril Ousmanou, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=head1 SEE ALSO

L<Tk::ForDummies::Graph>

=cut
