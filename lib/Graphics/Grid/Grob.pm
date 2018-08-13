package Graphics::Grid::Grob;

# ABSTRACT: Role for graphical object (grob) classes in Graphics::Grid

use Graphics::Grid::Role;

# VERSION

use Types::Standard qw(InstanceOf Maybe Str);
use namespace::autoclean;

use Graphics::Grid::GPar;
use Graphics::Grid::Types qw(:all);

=tmpl attr_vp

=attr vp

A viewport object. When drawing a grob, if the grob has this attribute, the
viewport would be temporily pushed onto the global viewport stack before drawing
takes place, and be poped after drawing. If the grob does not have this attribute
set, it would be drawn on the existing current viewport in the global viewport
stack. 

=tmpl

=cut

has vp => ( is => 'rw', isa => Maybe[ViewportLike] );

=tmpl attr_elems

=attr elems

Get number of sub-elements in the grob.

Grob classes shall implement a C<_build_elems()> method to support this
attribute.

=method length

This is an alias of C<elems>.

=tmpl 

=cut

has elems => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_elems',
    init_arg => undef
);

has name => ( is => 'rw', isa => Str, default => '' );

with qw(
  MooseX::Clone
  Graphics::Grid::HasGPar
);


# TODO: Make this a lazy attr, to avoid validating a grob for multiple times.
sub validate { }

requires '_build_elems';    # for attr "elems"

requires 'draw';

=method make_context()

A hook to allow a grob class to modify its vp before being drawn.

=cut

method make_context() {
    return $self->clone;
}

1;

__END__

=pod

=head1 DESCRIPTION

This is the role for graphical object (grob) classes.

=head1 SEE ALSO

L<Graphics::Grid>

