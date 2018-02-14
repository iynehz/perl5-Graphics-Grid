#!/usr/bin/env perl

use 5.014;
use warnings;

use Graphics::Grid::Functions qw(:all);

sub stick_person {
    my $gp = gpar( col => "blue", fill => "yellow", lwd => '3' );
    grid_circle( x => .5, y => .8, r => .1, gp => $gp );
    grid_lines( x => [ .5, .5 ],  y => [ .7, .2 ], gp => $gp );    # body
    grid_lines( x => [ .5, .7 ],  y => [ .6, .7 ], gp => $gp );    # right arm
    grid_lines( x => [ .5, .3 ],  y => [ .6, .7 ], gp => $gp );    # left arm
    grid_lines( x => [ .5, .65 ], y => [ .2, 0 ],  gp => $gp );    # right leg
    grid_lines( x => [ .5, .35 ], y => [ .2, 0 ],  gp => $gp );    # left leg
}

grid_rect();

for ( 1 .. 100 ) {
    my $vp = viewport( height => .9, width => .9 );
    push_viewport($vp);
    grid_rect();
}

up_viewport(0);    # get back to root viewport

grid_lines( x => [ .05, .95 ], y => [ .95, .05 ] );
grid_lines( x => [ .05, .95 ], y => [ .05, .95 ] );

for my $i ( 1 .. 20 ) {
    push_viewport( viewport( height => .9, width => .9 ) );

    # person 1:
    if ( $i == 5 ) {
        push_viewport( viewport( x => .8 ) );
        stick_person();
        up_viewport();
    }

    # person 2:
    if ( $i == 10 ) {
        push_viewport( viewport( x => .2, angle => 45 ) );
        stick_person();
        up_viewport();
    }

    # person 3:
    if ( $i == 20 ) {
        push_viewport( viewport( angle => -45 ) );
        stick_person();
    }
}

grid_write("foo.png");

