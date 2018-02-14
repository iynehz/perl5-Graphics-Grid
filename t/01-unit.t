#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Unit;

my @cases_constructor = (
    {
        params => [ value => 0.5 ],
        value  => [qw(0.5)],
        unit   => [qw(npc)],
    },
    {
        params => [ value => [qw(0.2 0.3)], unit => "in" ],
        value  => [qw(0.2 0.3)],
        unit   => [qw(inches)],
    },
    {
        params => [0.5],
        value  => [qw(0.5)],
        unit   => [qw(npc)],
    },
    {
        params => [ [qw(0.2 0.3)] ],
        value  => [qw(0.2 0.3)],
        unit   => [qw(npc)],
    },
    {
        params => [ value => [qw( 0.2 0.3 )], unit => [qw(npc in)] ],
        value  => [qw(0.2 0.3)],
        unit   => [qw(npc inches)],
    },
);

for my $case (@cases_constructor) {
    my $unit = Graphics::Grid::Unit->new( @{ $case->{params} } );
    ok( $unit, 'constructor' );
    is( $unit->value, $case->{value}, "value" );
    is( $unit->unit,  $case->{unit},  "unit" );
}

{
    my $unit = Graphics::Grid::Unit->new(
        value => [ 0.5,   1,        2,    3 ],
        unit  => [ "npc", "inches", "cm", 'mm' ]
    );
    is( $unit->elems, 4, 'elems' );
    my $as_cm = $unit->as_cm(100);
    is( $as_cm->value, [ 50, 2.54, 2, 0.3 ], 'as_cm' );
    is( $as_cm->unit, ['cm'], 'as_cm' );

}

done_testing;
