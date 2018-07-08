package Graphics::Grid::Grob::Points;

# ABSTRACT: Points grob

use Graphics::Grid::Class;

# VERSION

use namespace::autoclean;

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

=attr x

A Grahpics::Grid::Unit object specifying x-values.

Default to an array ref of 10 numbers from C<rand()>.

=attr y

A Grahpics::Grid::Unit object specifying y-values.

Default to an array ref of 10 numbers from C<rand()>.

C<x> and C<y> combines to define the points. C<x> and C<y> shall have same
length, which is the number of points in the grob object. 

=cut

=attr pch

Plotting character. A single value to indicate what sort of
plotting symbol to use.  See points for the interpretation of these values.

=cut 

has pch => (
    is      => 'ro',
    isa     => PlottingCharacter,
    default => 1
);

=attr

Graphics::Grid::Unit object specifying the size of the plotting symbols.  
Default to C<unit(1, "char")>.

=cut

has size => (
    is      => 'ro',
    isa     => Unit,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new( 1, "char" ) },
);

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> returns the number of points.

=cut

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

has '+x' => (
    default => sub {
        [ map { rand() } ( 0 .. 9 ) ]
    }
);
has '+y' => (
    default => sub {
        [ map { rand() } ( 0 .. 9 ) ]
    }
);

method _build_elems () {
    return $self->x->elems;
}

method validate () {
    unless (
        List::AllUtils::all { $self->$_->isa('Graphics::Grid::Unit') }
        qw(x y size)
      )
    {
        die "'x', 'y' and 'size' must be units";
    }

    my $x_size = $self->x->elems;
    my $y_size = $self->y->elems;
    unless ( $x_size == $y_size ) {
        die "'x' and 'y' must be 'unit' objects and have the same length";
    }
}

method draw ($driver) {
    $driver->draw_points($self);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Points;
    use Graphics::Grid::GPar;
    my $points = Graphics::Grid::Grob::Points->new(
        x => [ map { rand() } (0 .. 9) ],
        y => [ map { rand() } (0 .. 9) ],
        pch => "A",
        gp => Graphics::Grid::GPar->new());
    
    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $points = points_grob(%params);

=head1 DESCRIPTION

This class represents a "points" graphical object.

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

