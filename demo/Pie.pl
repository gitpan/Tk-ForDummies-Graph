  #!/usr/bin/perl
  use strict;
  use warnings;
  use Tk;
use lib 'Z:/djibril/Perso/Programmation/perl/COMPILATION/Tk-ForDummies-Graph/lib';
  use Tk::ForDummies::Graph::Pie;
  my $mw = new MainWindow( -title => 'Tk::ForDummies::Graph::Pie example', );

  my $GraphDummies = $mw->Pie(
    -title      => 'CPAN mirrors around the World',
    -background => 'white',
    -linewidth  => 2,
  )->pack(qw / -fill both -expand 1 /);

  my @data = (
    [ 'Europe', 'Asia', 'Africa', 'Oceania', 'Americas' ],
    [ 97,       33,     3,        6,         61 ],
  );

  $GraphDummies->plot( \@data );

  MainLoop();
