#!/usr/bin/perl
use strict;
use warnings;
use Tk;
use Tk::ForDummies::Graph::Boxplots;

my $mw = new MainWindow(
  -title      => 'Tk::ForDummies::Graph::Boxplots example',
  -background => 'white',
);

my $GraphDummies = $mw->Boxplots(
  -title      => 'My chart title',
  -xlabel     => 'X Label',
  -ylabel     => 'Y Label',
  -background => 'snow',
)->pack(qw / -fill both -expand 1 /);

my @data = (
  [ "1st", "2nd", "3rd", "4th", "5th" ],
  [ [ 100 .. 125, 136 .. 140 ],
    [ 22 .. 89 ],
    [ 12, 54, 88, 10 ],
    [ 12,      11, 23, 14 .. 98, 45 ],
    [ 0 .. 55, 11, 12 ]
  ],
  [ [ -25 .. -5, 1 .. 15 ],
    [ -45, 25 .. 45, 100 ],
    [ 70,  42 .. 125 ],
    [ 100, 30, 50 .. 78, 88, ],
    [ 180 .. 250 ]
  ],

  #...
);

# Add a legend to the chart
my @Legends = ( 'legend 1', 'legend 2' );
$GraphDummies->set_legend(
  -title => "Title legend",
  -data  => \@Legends,
);

# Add help identification
$GraphDummies->set_balloon();

# Create the chart
$GraphDummies->plot( \@data );

MainLoop();
