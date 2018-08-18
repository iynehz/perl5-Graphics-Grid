package Graphics::Grid::Grob::Rect;

# ABSTRACT: Rectangular grob

use Graphics::Grid::Class;

# VERSION

use List::AllUtils qw(max);
use namespace::autoclean;

=include attr_x_y@Graphics::Grid::Positional

=include attr_width_height@Graphics::Grid::Dimensional

=include attr_just@Graphics::Grid::HasJust

=include attr_gp@Graphics::Grid::HasGPar

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> returns the number of rectangles.

=cut

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
  Graphics::Grid::Dimensional
  Graphics::Grid::HasJust
);

method _build_elems() {
    return max( map { $self->$_->elems } qw(x y width height) );
}

method _draw($grid) {
    $grid->driver->draw_rect($self);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Rect;
    use Graphics::Grid::GPar;
    my $rect = Graphics::Grid::Grob::Rect->new(
            x => 0.5, y => 0.5, width => 1, height => 1,
            just => "centre",
            gp => Graphics::Grid::GPar->new());

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $rect = rect_grob(%params);

=head1 DESCRIPTION

This class represents a rectangular graphical object.    

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

