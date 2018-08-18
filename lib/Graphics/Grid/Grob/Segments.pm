package Graphics::Grid::Grob::Segments;

# ABSTRACT: Line segments grob

use Graphics::Grid::Class;

# VERSION

use Types::Standard qw(ArrayRef Int);
use namespace::autoclean;

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
    isa     => UnitLike,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new(0) }
);

has [qw(x1 y1)] => (
    is      => 'ro',
    isa     => UnitLike,
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

method _draw($grid) {
    $grid->driver->draw_segments($self);
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

