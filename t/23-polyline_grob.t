#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Grob::Lines;
use Graphics::Grid::Grob::Polygon;
use Graphics::Grid::Grob::Polyline;

my @cases_constructor_polyline = (
    {
        params => {},
    },
    {
        params => {
            x => [
                ( map { $_ / 10 } ( 0 .. 4 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5
            ],
            y => [
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } ( 0 .. 4 ) ),
            ],
            id => [ ( 1 .. 5 ) x 4 ],
            gp => Graphics::Grid::GPar->new(
                col => [qw(black red green3 blue cyan)],
                lwd => 3
            ),
        },
    },
    {   # nothing for id
        params => {
            x => [
                ( map { $_ / 10 } ( 0 .. 4 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5
            ],
            y => [
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } ( 0 .. 4 ) ),
            ],
            gp => Graphics::Grid::GPar->new(
                col => [qw(black red green3 blue cyan)],
                lwd => 3
            ),
        },
    },
);

my @cases_constructor_polygon = (
    {
        params => {},
    },
    {
        params => {
            x => [
                ( map { $_ / 10 } ( 0 .. 4 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5
            ],
            y => [
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } ( 0 .. 4 ) ),
            ],
            id => [ ( 1 .. 5 ) x 4 ],
            gp => Graphics::Grid::GPar->new(
                col => [qw(black red green3 blue cyan)],
            ),
        },
    },
);

for my $case (@cases_constructor_polyline) {
    my $grob = Graphics::Grid::Grob::Polyline->new( %{ $case->{params} } );
    ok( $grob, 'polyline constructor' );
}

for my $case (@cases_constructor_polygon) {
    my $grob = Graphics::Grid::Grob::Polygon->new( %{ $case->{params} } );
    ok( $grob, 'polygon constructor' );
}

done_testing;
