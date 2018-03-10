package Graphics::Grid::Grob::Segments;

# ABSTRACT: Line segments grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

use Types::Standard qw(ArrayRef Int);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

=attr x0

A Graphics::Grid::Unit object specifying the starting x-values of the line segments.

=attr y0

A Graphics::Grid::Unit object specifying the starting y-values of the line segments.

=attr x1

A Graphics::Grid::Unit object specifying the stopping x-values of the line segments.

=attr y1

A Graphics::Grid::Unit object specifying the stopping y-values of the line segments.

=cut

has [qw(x0 y0)] => (
    is      => 'ro',
    isa     => ValueWithUnit,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new(0) }
);

has [qw(x1 y1)] => (
    is      => 'ro',
    isa     => ValueWithUnit,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new(1) }
);

with qw(Graphics::Grid::Grob);

=include attr_gp@Graphics::Grid::HasGPar

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> always returns 1.

=cut

# TODO
# has arrow => ( isa => ArrayRef[$Arrow] );

method _build_elems() {
    return List::AllUtils::max( map { $self->$_->elems } qw(x0 y0 x1 y1) );
}

method _to_polyline() {
    my @x_value =
      map { ( $self->x0->value_at($_), $self->x1->value_at($_) ) }
      ( 0 .. $self->elems - 1 );
    my @x_unit =
      map { ( $self->x0->unit_at($_), $self->x1->unit_at($_) ) }
      ( 0 .. $self->elems - 1 );
    my @y_value =
      map { ( $self->y0->value_at($_), $self->y1->value_at($_) ) }
      ( 0 .. $self->elems - 1 );
    my @y_unit =
      map { ( $self->y0->unit_at($_), $self->y1->unit_at($_) ) }
      ( 0 .. $self->elems - 1 );
    my $id = [ map { ( $_, $_ ) } ( 0 .. $self->elems - 1 ) ];

    my %params = (
        x  => Graphics::Grid::Unit->new( \@x_value, \@x_unit ),
        y  => Graphics::Grid::Unit->new( \@y_value, \@y_unit ),
        id => $id,
        ( map { $_ => $self->$_ } grep { defined $self->$_ } qw(gp vp) )
    );
    return Graphics::Grid::Grob::Polyline->new(%params);
}

method draw($driver) {
    $driver->draw_polyline( $self->_to_polyline );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Segments;
    use Graphics::Grid::GPar;
    my $lines = Graphics::Grid::Grob::Segments->new(
            x0 => 0, y0 => 0,
            x1 => 1, y1 => 1,
            gp => Graphics::Grid::GPar->new()
    );

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $lines = segments_grob(%params);

=head1 DESCRIPTION

This class represents a "line segments" graphical object. It's a little bit
similar to L<Graphics::Grid::Grob::Polyline> in that a segments grob can
also be implemented by a ployline grob.

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

L<Graphics::Grid::Grob::Polyline>

