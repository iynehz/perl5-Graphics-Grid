package Graphics::Grid::Grob::Circle;

# ABSTRACT: Circle grob

use Graphics::Grid::Class;

# VERSION

use List::AllUtils qw(max);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

=attr r

Radius of the circle. Default is 0.5 npc, relative to the smaller
one of viewport's width and height.

=cut

has r => (
    is      => 'ro',
    isa     => ValueWithUnit,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new(0.5) }
);

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

method _build_elems() {
    return max( map { $self->$_->elems } qw(x y r) );
}

method draw($driver) {
    $driver->draw_circle($self);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Circle;
    use Graphics::Grid::GPar;

    my $rect = Graphics::Grid::Grob::Circle->new(
            x => 0.5, y => 0.5, r => 0.5,
            gp => Graphics::Grid::GPar->new());

=head1 DESCRIPTION

This class represents a circle graphical object.

=head1 CONSTRUCTOR

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

