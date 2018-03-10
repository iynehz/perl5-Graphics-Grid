package Graphics::Grid::Grob::Polygon;

# ABSTRACT: Polygon grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

extends qw(Graphics::Grid::Grob::Polyline);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

=attr x

A Grahpics::Grid::Unit object specifying x-values.

Default to C<unit([0, 0.5, 1, 0.5], "npc")>.

=attr y

A Grahpics::Grid::Unit object specifying y-values.

Default to C<unit([0.5, 1, 0.5, 0], "npc")>.

=include attr_id@Graphics::Grid::Grob::Polyline

=include attr_gp@Graphics::Grid::HasGPar

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> returns the number of polygons. 

=cut

with qw(
  Graphics::Grid::Positional
);

has '+x' =>
  ( default => sub { Graphics::Grid::Unit->new( [ 0, 0.5, 1, 0.5 ] ) } );

has '+y' =>
  ( default => sub { Graphics::Grid::Unit->new( [ 0.5, 1, 0.5, 0 ] ) } );

method draw($driver) {
    $driver->draw_polygon($self);
}

__PACKAGE__->meta->make_immutable;

1;


__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Polygon;
    use Graphics::Grid::GPar;
    my $polygon = Graphics::Grid::Grob::Polygon->new(
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
                fill => [qw(black red green3 blue cyan)],
            )
    );

    # or user the function interface
    use Graphics::Grid::Functions qw(:all);
    my $polygon = polygon_grob(%params);

=head1 DESCRIPTION

This class represents a polygon graphical object. It is a sub class of
L<Graphics::Grid::Grob::Polyline>. The difference is that when a
polyline is drawn, the path is closed and C<fill> in C<gp> can take
effect.

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

L<Graphics::Grid::Grob::Polyline>
