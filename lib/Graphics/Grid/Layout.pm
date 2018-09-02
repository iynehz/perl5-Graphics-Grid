package Graphics::Grid::Layout;

# ABSTRACT: layout

use Graphics::Grid::Class;

# VERSION

use Eval::Closure;
use List::AllUtils qw(minmax reduce);
use Types::Standard qw(Bool Int InstanceOf Str);
use namespace::autoclean;

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

with qw(MooseX::Clone);

my $PositiveInt = Int->where( sub { $_ > 0 } );

=attr nrow

Number of rows in the layout.

=attr ncol

Number of columns in the layout.

=cut

has nrow =>
  ( is => 'ro', isa => $PositiveInt, writer => '_set_nrow', default => 1 );
has ncol =>
  ( is => 'ro', isa => $PositiveInt, writer => '_set_ncol', default => 1 );

=attr width

=attr height

=cut

has widths => (
    is      => 'ro',
    isa     => UnitLike,
    writer  => '_set_widths',
    lazy    => 1,
    builder => '_build_widths'
);
has heights => (
    is      => 'ro',
    isa     => UnitLike,
    writer  => '_set_heights',
    lazy    => 1,
    builder => '_build_heights'
);

method _build_widths () {
    return Graphics::Grid::Unit->new( [ (1) x $self->ncol ], "null" );
}

method _build_heights () {
    return Graphics::Grid::Unit->new( [ (1) x $self->nrow ], "null" );
}

=attr respect

Boolean value for whether row heights and column widths should respect each
other. 

=cut

has respect => ( is => 'rw', isa => Bool, default => 0 );

with qw(Graphics::Grid::HasJust);

=method dims

=cut

method dims () { return ( $self->row, $self->ncol ); }

=method cell_width($cell_indices)

Returns the width of a cell.

=method cell_height($cell_indices)

Returns the height of a cell.

=cut

method cell_width ($cell_indices) {
    my ( $min_idx, $max_idx ) = minmax(@$cell_indices);
    return (
        reduce { $a + $b }
        map { $self->widths->at($_) } ( $min_idx .. $max_idx )
    );
}

method cell_height ($cell_indices) {
    my ( $min_idx, $max_idx ) = minmax(@$cell_indices);
    return (
        reduce { $a + $b }
        map { $self->heights->at($_) } ( $min_idx .. $max_idx )
    );
}

=method width()

Returns the width of the layout (sum of C<widths>) as a
Graphics::Grid::UnitArithmetic object.

=method height()

Returns the height of the layout (sum of C<heights>) as a
Graphics::Grid::UnitArithmetic object.

=cut

method width () { return $self->cell_width(  [ 0 .. $self->ncol - 1 ] ); }
method height () { return $self->cell_height( [ 0 .. $self->nrow - 1 ] ); }

# return a new layout object
method _process_null_unit () {

    # https://www.stat.auckland.ac.nz/~paul/grid/doc/R-1.8.0/nullunit.pdf
    #
    # if the layout width/height only involves "null" units then evaluate
    # the total value and treat the result as the specification of a
    # relative width/height, but if there are any non-"null" units in the
    # width/height expression then evaluate the "null" units as if they are
    # outside of the layout. (that is, a "null" unit means zero.)

    my $is_widths_null_unit  = $self->widths->is_null_unit;
    my $is_heights_null_unit = $self->heights->is_null_unit;

    return $self
      unless ( $is_widths_null_unit and $is_heights_null_unit );

    my $to_npc = fun($x) {
        my @values = map {
            my $s = ( $x->at($_)->string =~ s/null//gr );
            eval_closure( source => "sub { $s }" )->();
        } ( 0 .. $x->elems - 1 );
        my $sum = List::AllUtils::sum(@values);
        return Graphics::Grid::Unit->new( [ map { $_ / $sum } @values ],
            'npc' );
    };

    my $layout = $self->clone;

    if ($is_widths_null_unit) {
        $layout->_set_widths( $to_npc->( $layout->widths ) );
    }
    if ($is_heights_null_unit) {
        $layout->_set_heights( $to_npc->( $layout->heights ) );
    }
    return $layout;
}

1;

__END__


=head1 SYNOPSIS

    use Graphics::Grid::Functions qw(:all);

    sub testlay {
        my $just = shift // "center";       

        push_viewport(viewport(
            layout => grid_layout(
                nrow => 1, ncol => 1,
                widths => unit(1, "inches"), heights => unit(0.25, "npc"),
                just => $just)));
        push_viewport(viewport(layout_pos_col => 0, layout_pos_row => 0));
        grid_rect();
        grid_text($just);
        pop_viewport(2)
    }

    for my $just (qw(center left_top right_top right_bottom left_bottom
                     left right bottom top)) {
        testplay($just);
    }

=head1 DESCRIPTION

A grid layout describes a subdivision of a rectangular region.

=head1 SEE ALSO

L<Graphics::Grid>

