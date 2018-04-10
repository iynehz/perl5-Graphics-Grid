#!perl

use strict;
use warnings;

use Test2::V0;

use Graphics::Grid::Functions qw(:all);
use Graphics::Grid::Driver::Cairo;

pass("Graphics::Grid::Functions loads");

{
    my $driver = grid_driver( width => 800, height => 600 );
    is( [ $driver->width, $driver->height ], [ 800, 600 ], 'grid_driver()' );
}

{
    my $driver = Graphics::Grid::Driver::Cairo->new();
    my $driver_out = grid_driver(driver => $driver);
    is( [ $driver->width, $driver->height ], [ 1000, 1000 ], 'grid_driver()' );
}

done_testing;
