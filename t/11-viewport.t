#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Unit;
use Graphics::Grid::Layout;
use Graphics::Grid::Viewport;
use Graphics::Grid::ViewportTree;

{
    my @cases_constructor = (
        { params => {} },
        { params => { width => 0.5, height => 0.5 } },
        {
            params => {
                layout => Graphics::Grid::Layout->new(
                    nrow    => 1,
                    ncol    => 1,
                    widths  => Graphics::Grid::Unit->new( 1, "inches" ),
                    heights => Graphics::Grid::Unit->new( 0.25, "npc" )
                )
            }
        },
        { params => { layout_pos_col => 1, layout_pos_row => 1 } },
    );

    for my $case (@cases_constructor) {
        my $vp = Graphics::Grid::Viewport->new(%{$case->{params}});
        ok( $vp, 'construction' );
    }

    #my $vp = Graphics::Grid::Viewport->new( width => 0.5, height => 0.5 );
    #ok( $vp, 'construction' );

    #is( $vp->name, 'GRID.VP.0', "default name starts with 'GRID.VP.0'" );
    #is( Graphics::Grid::Viewport->new()->name,
    #    'GRID.VP.1', "default name generted is unique'" );
}

# Tree
{
    my ( $a, $b, $c, $d ) =
      map { Graphics::Grid::Viewport->new( name => $_ ) } qw(A B C D);
    my $tree = Graphics::Grid::ViewportTree->new(
        node     => $a,
        children => [
            $b,
            Graphics::Grid::ViewportTree->new(
                node     => $c,
                children => [$d]
            ),
        ]
    );
    is( $tree->stringify,
        'Viewport[A]->(Viewport[B],Viewport[C]->(Viewport[D]))', 'stringify' );
}

done_testing;
