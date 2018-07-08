package Graphics::Grid::Grob::Polyline;

# ABSTRACT: Polyline grob

use Graphics::Grid::Class;

# VERSION

use List::AllUtils qw(uniq);
use Types::Standard qw(ArrayRef Int);
use namespace::autoclean;

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

=tmpl attr_x_y

=attr x

A Grahpics::Grid::Unit object specifying x-values.

Default to C<unit([0, 1], "npc")>.

=attr y

A Grahpics::Grid::Unit object specifying y-values.

Default to C<unit([0, 1], "npc")>.

C<x> and C<y> combines to define the points in the lines. C<x> and C<y> shall
have same length. For example, the default values of C<x> and C<y> defines
a line from point (0, 0) to (1, 1). If they have less than two elements, it
is surely not enough to make a line and nothing would be drawn.

=tmpl

=tmpl attr_id

=attr id

An array ref used to separate locations in x and y into multiple lines. All
locations with the same id belong to the same line.

C<id> needs to have the same length as C<x> and C<y>.

If C<id> is not specified then all points would be regarded as being in one
line.  

=tmpl

=cut

has id => (
    is  => 'ro',
    isa => ArrayRef [Int]
);

# TODO
# has arrow => ( isa => ArrayRef[$Arrow] );

has _indexes_by_id => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build__indexes_by_id',
    init_arg => undef
);

has _ids => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build__ids',
    init_arg => undef,
);

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

has [qw(+x +y)] => (
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new( [ 0, 1 ] ) }
);

=include attr_gp@Graphics::Grid::HasGPar

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> returns the number of lines (number of unique
C<id>) of a object.

=cut

method _build_elems () {
    return scalar( @{ $self->_ids } );
}

method _build__ids () {
    if ( !$self->has_id ) {
        return [0];
    }
    else {
        my @ids = uniq( @{ $self->id } );
        return \@ids;
    }
}

method _build__indexes_by_id () {
    if ( !$self->has_id ) {
        return { 0 => [ 0 .. $self->x->elems - 1 ] };
    }
    else {
        my %indexes_by_id = map { $_ => [] } @{ $self->id };
        for my $idx ( 0 .. $#{ $self->id } ) {
            my $id = $self->id->[$idx];
            push @{ $indexes_by_id{$id} }, $idx;
        }
        return \%indexes_by_id;
    }
}

=method indexes_by_id($id)

Get unit indexes of attributes C<x>, C<y>, C<id>, for a given id.

Returns an array ref.

=cut

method indexes_by_id ($id) {
    return $self->_indexes_by_id->{$id};
}

=method unique_ids

Return an array ref of unique ids.

=cut

method unique_ids () {
    return $self->_ids;
}

method get_idx_by_id ($id) {
    my @indexes = map { $_ == $id } @{ $self->id };
    return \@indexes;
}

method _has_param ($name) {
    my $val = $self->$name;
    return ( defined $val and @{$val} > 0 );
}

for my $name (qw(id arrow)) {
    no strict 'refs';    ## no critic
    *{ "has_" . $name } = sub { $_[0]->_has_param($name); }
}

method validate () {
    my $x_size = $self->x->elems;
    my $y_size = $self->y->elems;
    unless ( $x_size == $y_size ) {
        die "'x' and 'y' must have the same length";
    }
    if ( $self->has_id and $x_size != scalar( @{ $self->id } ) ) {
        die "'x', 'y' and 'id' must have the same length";
    }
}

method draw ($driver) {
    $driver->draw_polyline($self);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Polyline;
    use Graphics::Grid::GPar;
    my $polyline = Graphics::Grid::Grob::Polyline->new(
            x => [
                ( map { $_ / 10 } ( 0 .. 4 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5
            ],
            y => [
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } ( 0 .. 4 ) ),
            ],
            id => [ ( 1 .. 5 ) x 4 ],
            gp => Graphics::Grid::GPar->new(
                col => [qw(black red green3 blue cyan)],
                lwd => 3,
            )
    );

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $polyline = polyline_grob(%params);

=head1 DESCRIPTION

This class represents a polyline graphical object.

=head1 CONSTRUCTOR

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

