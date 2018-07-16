#!perl

use 5.014;
use warnings;

use Graphics::Grid::Functions qw(:all);

sub test_layout {
    my ($just) = @_;

    push_viewport(
        viewport(
            layout => grid_layout(
                nrow    => 2,
                ncol    => 1,
                widths  => unit( 1.5, "inches" ),
                heights => unit( [ 0.15, 0.1 ], "npc" ),
                just    => $just
            )
        )
    );
    push_viewport( viewport( layout_pos_col => 0, layout_pos_row => 0 ) );
    grid_rect();
    grid_text( label => $just . " A" );
    pop_viewport(1);
    push_viewport( viewport( layout_pos_col => 0, layout_pos_row => 1 ) );
    grid_rect();
    grid_text( label => $just . " B" );

    pop_viewport(2);
}

sub test_layout2 {
    my ($just) = @_;

    push_viewport(
        viewport(
            layout => grid_layout(
                nrow    => 1,
                ncol    => 2,
                widths  => unit( [ 1, 0.5 ], "inches" ),
                heights => unit( 0.25, "npc" ),
                just    => $just
            )
        )
    );
    push_viewport( viewport( layout_pos_col => 0, layout_pos_row => 0 ) );
    grid_rect();
    grid_text( label => $just . " A", rot => 90 );
    pop_viewport(1);
    push_viewport( viewport( layout_pos_col => 1, layout_pos_row => 0 ) );
    grid_rect();
    grid_text( label => $just . " B", rot => 90 );

    pop_viewport(2);
}

grid_rect();

my $i = 0;
for my $just (
    qw(
    left_top top right_top
    right center left
    right_bottom bottom left_bottom
    )
  )
{
    if ( $i++ % 2 == 1 ) {
        test_layout($just);
    }
    else {
        test_layout2($just);
    }
}

grid_write("layout.png");

