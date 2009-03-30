use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Tk::ForDummies::Graph',
    license             => 'perl',
    dist_author         => 'Djibril Ousmanou <djibrilo@yahoo.fr>',
    dist_version_from   => 'lib/Tk/ForDummies/Graph.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Tk-ForDummies-Graph-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
