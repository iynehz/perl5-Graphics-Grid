#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Unit;

DOES_ok( 'Graphics::Grid::Unit', [qw(Graphics::Grid::UnitLike)] );

my @cases_constructor = (
    {
        params => [42],
        value  => [42],
        unit   => ['npc'],
    },
    {
        params => [ [42] ],
        value  => [42],
        unit   => ['npc'],
    },
    {
        params => [ 42, 'npc' ],
        value  => [42],
        unit   => ['npc'],
    },
    {
        params => [ [42], ['npc'] ],
        value  => [42],
        unit   => ['npc'],
    },
    {
        params => [ value => 42 ],
        value  => [42],
        unit   => ['npc'],
    },
    {
        params => [ value => [42] ],
        value  => [42],
        unit   => ['npc'],
    },
    {
        params => [ value => 42, unit => 'npc' ],
        value  => [42],
        unit   => ['npc'],
    },
    {
        params => [ value => [42], unit => ['npc'] ],
        value  => [42],
        unit   => ['npc'],
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
    {
        params => [ 1, 'char' ],
        value  => [qw(1)],
        unit   => [qw(char)],
    },
    {
        params => [ 1, 'native' ],
        value  => [qw(1)],
        unit   => [qw(native)],
    },
);

for my $case (@cases_constructor) {
    my $unit = Graphics::Grid::Unit->new( @{ $case->{params} } );
    ok( $unit, 'constructor' );
    is( $unit->value, $case->{value}, "value" );
    is( $unit->unit,  $case->{unit},  "unit" );
}

{
    my $u1 = Graphics::Grid::Unit->new( [ 1 .. 3 ], 'npc' );
    my $u2 = Graphics::Grid::Unit->new( [ 1 .. 3 ], [ ('npc') x 3 ] );
    my $u3 = Graphics::Grid::Unit->new( [ 1 .. 2 ], [ ('npc') x 3 ] );
    my $u4 = Graphics::Grid::Unit->new( [ 4 .. 6 ], 'cm' );

    ok( $u1 == $u2, '==' );
    ok( $u1 != $u3, '!=' );
    ok( $u1 eq $u2, 'eq' );
    ok( $u1 ne $u3, 'ne' );

    is( $u1->slice( [ 1, 2 ] )->string, '2npc, 3npc', 'slice()' );

    my $appended = $u1->append($u4);
    isa_ok( $appended, ['Graphics::Grid::Unit'],
        '$unit->append($another_unit) results a unit' );
    is( $appended->string, '1npc, 2npc, 3npc, 4cm, 5cm, 6cm', 'append()' );

    is( $u1->insert( $u4, 1 )->string,
        '1npc, 2npc, 4cm, 5cm, 6cm, 3npc', 'insert()' );
    is(
        $u1->insert( $u4, -1 )->string,
        $u4->append($u1)->string,
        'insert() before'
    );
    is(
        $u1->insert( $u4, 3 )->string,
        $u1->append($u4)->string,
        'insert() after'
    );

    ok( !$u1->is_null_unit, 'is_null_unit()' );
    ok( !Graphics::Grid::Unit->new( [ 1, 1 ], [ 'npc', 'null' ] )->is_null_unit,
        'is_null_unit()' );
    ok( Graphics::Grid::Unit->new( [ 1, 1 ], 'null' )->is_null_unit,
        'is_null_unit()' );
}

ok( Graphics::Grid::Unit->is_absolute_unit('cm'),   'is_absolute_unit' );
ok( !Graphics::Grid::Unit->is_absolute_unit('npc'), 'is_absolute_unit' );

done_testing;
