#!/usr/bin/perl
use strict;
use warnings;
use Tk;
use Tk::ForDummies::Graph::Lines;

my $mw = new MainWindow(
  -title      => 'bezier curve example',
  -background => 'white',
);
my $GraphDummies = $mw->Lines(
  -title      => 'My chart title',
  -xlabel     => 'X Label',
  -ylabel     => 'Y Label',
  -background => 'snow',
  -smoothline => 1,
  -linewidth  => 2,
)->pack(qw / -fill both -expand 1 /);

my @data
  = ( [ '1st', '2nd', '3rd' ], [ 10, 30, 10, ], [ 10, 0, 10, ], [ 20, 10, 30, ],
  );

# Add a legend to the chart
my @Legends = ( 'legend 1', 'legend 2', 'legend 3' );
$GraphDummies->set_legend(
  -title       => "Title legend",
  -data        => \@Legends,
  -titlecolors => "blue",
);

# Add help identification
$GraphDummies->set_balloon();

# Create the chart
$GraphDummies->plot( \@data );

MainLoop();
