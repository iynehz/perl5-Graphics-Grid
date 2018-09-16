package Graphics::Grid::Grob::Circle;

# ABSTRACT: Circle grob

use Graphics::Grid::Class;

# VERSION

use List::AllUtils qw(max);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

=include attr_x_y@Graphics::Grid::Positional

=attr r

Radius of the circle. Default is 0.5 npc relative to the smaller
one of viewport's width and height.

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> returns the number of circles.

=cut

has r => (
    is      => 'ro',
    isa     => UnitLike,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new(0.5) }
);

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

method _build_elems () {
    return max( map { $self->$_->elems } qw(x y r) );
}

method _draw ($grid) {
    return $grid->driver->draw_circle($self);
}

#method extents ($grid) {
#    my @v =
#      map { $grid->driver->_transform_width_to_cm( $self->r, $_ ); }
#      ( 0 .. $self->elems - 1 );
#    return Graphics::Grid::Unit->new( \@v, 'cm' );
#}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Circle;
    use Graphics::Grid::GPar;
    my $circle = Graphics::Grid::Grob::Circle->new(
            x => 0.5, y => 0.5, r => 0.5,
            gp => Graphics::Grid::GPar->new());

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $circle = circle_grob(%params);

=head1 DESCRIPTION

This class represents a circle graphical object.

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

