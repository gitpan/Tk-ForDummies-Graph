#!perl -T

use Test::More tests => 7;

BEGIN {
	use_ok( 'Tk::ForDummies::Graph' );
	use_ok( 'Tk::ForDummies::Graph::Lines' );
	use_ok( 'Tk::ForDummies::Graph::Areas' );
	use_ok( 'Tk::ForDummies::Graph::Bars' );
	use_ok( 'Tk::ForDummies::Graph::Utils' );
	use_ok( 'Tk::ForDummies::Graph::Boxplots' );
	use_ok( 'Tk::ForDummies::Graph::Pie' );
}

diag( "Testing Tk::ForDummies::Graph $Tk::ForDummies::Graph::VERSION, Perl $], $^X" );
