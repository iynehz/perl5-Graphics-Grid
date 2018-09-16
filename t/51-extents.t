#!perl

use Graphics::Grid::Setup;

use Test2::V0;

use Graphics::Grid;
use Graphics::Grid::ViewportTree;

my $grid = Graphics::Grid->new;

my $text = Graphics::Grid::Grob::Text->new(
    label => 'Hello, world!',
    gp    => { fontsize => 20 },
);
my $extents = $text->extents($grid);
isa_ok( $extents, ['Graphics::Grid::Extents'], 'extents' );
diag( Dumper($extents) );

done_testing;
