package Graphics::Grid::Grob::Polygon;

# ABSTRACT: Polygon grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

extends qw(Graphics::Grid::Grob::Polyline);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

has '+x' =>
  ( default => sub { Graphics::Grid::Unit->new( [ 0, 0.5, 1, 0.5 ] ) } );

has '+y' =>
  ( default => sub { Graphics::Grid::Unit->new( [ 0.5, 1, 0.5, 0 ] ) } );

with qw(
  Graphics::Grid::Positional
);

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
                col => [qw(black red green3 blue cyan)],
            )
    );

=head1 DESCRIPTION

This class represents a polygon graphical object.

=head1 CONSTRUCTOR

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

