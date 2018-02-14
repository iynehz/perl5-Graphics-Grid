package Graphics::Grid::Grob::Rect;

# ABSTRACT: Rectangular grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

use List::AllUtils qw(max);

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
  Graphics::Grid::Dimensional
  Graphics::Grid::Justifiable
);

method _build_elems() {
    return max( map { $self->$_->elems } qw(x y width height) );
}

method draw($driver) {
    $driver->draw_rect($self);
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
            just => "centre", gp => Graphics::Grid::GPar->new());

=head1 DESCRIPTION

This class represents a rectangular graphical object.    

=head1 CONSTRUCTOR

Valid parameter names are:

=over 4

=item *

x

A numeric arrayref or unit object specifying x-location.

=item *

y

A numeric arrayref or unit object specifying y-location.

=item *

width

A numeric arrayref or unit object specifying width.

=item *

height

A numeric vector or unit object specifying height.

=item *

just

The justification of the rectangle relative to its (x, y) location.

=item *

gp

A Graphics::Grid::GPar object. 

=back

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

