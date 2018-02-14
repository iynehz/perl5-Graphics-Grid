package Graphics::Grid::Grob;

# ABSTRACT: Role for graphical object (grob) classes in Graphics::Grid

use Graphics::Grid::Role;

# VERSION

use Types::Standard qw(InstanceOf Str);
use namespace::autoclean;

use Graphics::Grid::GPar;
use Graphics::Grid::Types qw(:all);

=attr elems

Get number of sub-elements in the grob.

Grob classes shall implement a C<_build_elems()> method to support this
attribute.

=cut

has elems => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_elems',
    init_arg => undef
);

has name => ( is => 'ro', isa => Str, default => '' );

=attr vp

A viewport object. When drawing a grob, if the grob has this attribute, the
viewport would be temporily pushed onto the global viewport stack before drawing
takes place, and be poped after drawing. If the grob does not have this attribute
set, it would be drawn on the existing current viewport in the global viewport
stack. 

=cut

has vp => ( is => 'ro', isa => InstanceOf ["Graphics::Grid::Viewport"] );

with qw(
  Graphics::Grid::HasGPar
);


# TODO: Make this a lazy attr, to avoid validating a grob for multiple times.
sub validate { }

requires '_build_elems';    # for attr "elems"

requires 'draw';

1;

__END__

=pod

=head1 DESCRIPTION

This is the role for graphical object (grob) classes.

=head1 SEE ALSO

L<Graphics::Grid>

