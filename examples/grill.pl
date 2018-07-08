#!/usr/bin/env perl

use 5.014;
use warnings;

use Graphics::Grid::Functions qw(:all);

grid_rect( gp => { fill => 'grey' } );

grid_grill(
    h  => [0.5],
    v  => [ 0.2, 0.4, 0.6, 0.8 ],
    gp => gpar( col => "red" ),
);

grid_write("grill.png");

