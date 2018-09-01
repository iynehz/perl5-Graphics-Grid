#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Unit;
use Graphics::Grid::UnitArithmetic;
use Graphics::Grid::UnitList;

DOES_ok( 'Graphics::Grid::UnitArithmetic', [qw(Graphics::Grid::UnitLike)] );
DOES_ok( 'Graphics::Grid::UnitList',       [qw(Graphics::Grid::UnitLike)] );

my @cases_constructor = (

    {
        params => [
            node => 42,
        ],
        elems  => 1,
        string => '42',
    },
    {
        params => [
            node => [42],
        ],
        elems  => 1,
        string => '42',
    },

    {
        params => [
            node     => '-',
            children => [
                Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ),
                Graphics::Grid::Unit->new(0.5),
            ],
        ],
        elems  => 3,
        string => '1cm-0.5npc, 2cm-0.5npc, 3cm-0.5npc',
    },
    {
        params => [
            node     => '*',
            children => [
                [2],
                Graphics::Grid::UnitArithmetic->new(
                    node     => '+',
                    children => [
                        Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ),
                        Graphics::Grid::Unit->new(0.5),
                    ],
                ),
            ],
        ],
        elems  => 3,
        string => '2*(1cm+0.5npc), 2*(2cm+0.5npc), 2*(3cm+0.5npc)',
    },
    {
        params => [
            node     => '*',
            children => [
                Graphics::Grid::UnitArithmetic->new(
                    node     => '+',
                    children => [
                        Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ),
                        Graphics::Grid::Unit->new(0.5),
                    ],
                ),
                [2],
            ],
        ],
        elems  => 3,
        string => '(1cm+0.5npc)*2, (2cm+0.5npc)*2, (3cm+0.5npc)*2',
    },
);

for my $case (@cases_constructor) {
    my $ua =
      Graphics::Grid::UnitArithmetic->new( @{ $case->{params} } );
    ok( $ua, 'constructor' );
    if ( exists $case->{elems} ) {
        is( $ua->elems, $case->{elems}, 'elems()' );
    }

    if ( exists $case->{string} ) {
        is( $ua->string, $case->{string}, 'string()' );
    }
    else {
        diag( $ua->string );
    }

}

{
    my $ua1 =
      Graphics::Grid::UnitArithmetic->new(
        node => Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ) );
    is( ( $ua1 * 2 )->string, '1cm*2, 2cm*2, 3cm*2', 'ua overload +/-/*' );

    my $ua2 =
      ( Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ) +
          Graphics::Grid::Unit->new(0.5) ) * 2;

    is( $ua2->sum->string, '(1cm+0.5npc)*2+(2cm+0.5npc)*2+(3cm+0.5npc)*2',
        'sum' );
    is( $ua2->slice( [ 1, 2 ] )->string,
        '(2cm+0.5npc)*2, (3cm+0.5npc)*2', 'slice()' );

    is(
        $ua2->string,
        '(1cm+0.5npc)*2, (2cm+0.5npc)*2, (3cm+0.5npc)*2',
        'overload +/-/*'
    );

    is( ( $ua2 + undef )->string, $ua2->string, '+undef' );
    is( ( $ua2 - undef )->string, $ua2->string, '-undef' );

    my $u1 = Graphics::Grid::Unit->new( 1, "npc" );

    my $ul1 = $ua2->append($u1);
    isa_ok(
        $ul1,
        ['Graphics::Grid::UnitList'],
        '$unitarithmetic->append($another_unit) results a unitlist'
    );
    is( $ul1->string, '(1cm+0.5npc)*2, (2cm+0.5npc)*2, (3cm+0.5npc)*2, 1npc',
        '$ua->append()' );

    is(
        $u1->append($ua2)->string,
        '1npc, (1cm+0.5npc)*2, (2cm+0.5npc)*2, (3cm+0.5npc)*2',
        '$ua->append()'
    );

    is(
        $ul1->slice( [ 2, 3 ] )->string,
        '(3cm+0.5npc)*2, 1npc',
        '$ul->slice()'
    );
    is(
        $ul1->insert( $ua1, 0 )->string,
        '(1cm+0.5npc)*2, 1cm, 2cm, 3cm, (2cm+0.5npc)*2, (3cm+0.5npc)*2, 1npc',
        '$ul->insert()'
    );

    is(
        ( $ul1 + $ua1 )->string,
        '(1cm+0.5npc)*2+1cm, (2cm+0.5npc)*2+2cm, (3cm+0.5npc)*2+3cm, 1npc+1cm',
        'ul overload +'
    );
}

done_testing;

