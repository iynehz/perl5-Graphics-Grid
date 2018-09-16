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
        elems        => 3,
        string       => '1cm-0.5npc, 2cm-0.5npc, 3cm-0.5npc',
        is_null_unit => 0,
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
        elems        => 3,
        string       => '2*(1cm+0.5npc), 2*(2cm+0.5npc), 2*(3cm+0.5npc)',
        is_null_unit => 0,
    },
    {
        params => [
            node     => '*',
            children => [
                Graphics::Grid::UnitArithmetic->new(
                    node     => '+',
                    children => [
                        Graphics::Grid::Unit->new( [ 1, 2, 3 ], "null" ),
                        Graphics::Grid::Unit->new( 0.5, 'null' ),
                    ],
                ),
                [2],
            ],
        ],
        elems  => 3,
        string => '(1null+0.5null)*2, (2null+0.5null)*2, (3null+0.5null)*2',
        is_null_unit => 1,
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
    if ( exists $case->{is_null_unit} ) {
        my $ok = $case->{is_null_unit} ? $ua->is_null_unit : !$ua->is_null_unit;
        ok( $ok, 'is_null_unit()' );
    }
}

{
    my $ua1 =
      Graphics::Grid::UnitArithmetic->new(
        node => Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ) );
    is( ( $ua1 * 2 )->string, '1cm*2, 2cm*2, 3cm*2', 'ua overload +/-/*' );

    my $reduced1 = ( $ua1 * 2 )->reduce();
    isa_ok( $reduced1, ['Graphics::Grid::Unit'], 'reduce' );
    is( $reduced1->string, '2cm, 4cm, 6cm', 'reduce' );

    my $reduced2 =
      ( $ua1 * [ 1 .. 4 ] + Graphics::Grid::Unit->new( [ 1, 2, 3 ], "mm" ) )
      ->reduce;
    isa_ok( $reduced2, ['Graphics::Grid::Unit'], 'reduce' );
    is( $reduced2->string, '1.1cm, 4.2cm, 9.3cm, 4.1cm', 'reduce' );

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

    ok( !$ul1->is_null_unit(), '$ul->is_null_unit' );

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

{
    my $u1 = Graphics::Grid::Unit->new( [ 1, 2, 3 ], 'null' );
    my $u2 = Graphics::Grid::Unit->new( [ 4, 5 ], 'null' );
    my $ul2 = $u1->append( $u2 * 2 );

    is( $ul2->elems, 5, '$ul->elems' );
    ok( $ul2->is_null_unit, '$ul->is_null_unit' );
}

done_testing;

