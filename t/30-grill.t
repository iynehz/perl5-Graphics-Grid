#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Grill;
use Graphics::Grid::Functions qw(unit gpar);

my @cases_constructor = (
    {
        params => [],
    },
    {
        params => [
            h => unit( [ 0.25, 0.5, 0.75 ] ),
            v => unit( [ 0.25, 0.5, 0.75 ] ),
            gp => gpar( col => "grey" )
        ],
    },
);

for my $case (@cases_constructor) {
    my $grob = Graphics::Grid::Grill->new( @{ $case->{params} } );
    ok( $grob, 'constructor' );
}

done_testing;
