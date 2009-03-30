#!perl -T

use Test::More tests => 3;

BEGIN {
	use_ok( 'Tk::ForDummies::Graph' );
	use_ok( 'Tk::ForDummies::Graph::Lines' );
	use_ok( 'Tk::ForDummies::Graph::Pie' );
}

diag( "Testing Tk::ForDummies::Graph $Tk::ForDummies::Graph::VERSION, Perl $], $^X" );
