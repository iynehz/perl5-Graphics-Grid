#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Unit;
use Graphics::Grid::Layout;

my @cases_constructor = (
    {
        params => {},
        params => {
            nrow    => 1,
            ncol    => 1,
            widths  => Graphics::Grid::Unit->new( 1, "inches" ),
            heights => Graphics::Grid::Unit->new( 0.25, "npc" )
        },
    },
);

for my $case (@cases_constructor) {
    my $grob = Graphics::Grid::Layout->new( %{ $case->{params} } );
    ok( $grob, 'constructor' );
}

done_testing;
