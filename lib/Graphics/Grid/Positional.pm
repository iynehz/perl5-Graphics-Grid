package Graphics::Grid::Positional;

# ABSTRACT: Role for supporting (x, y) position in Graphics::Grid

use Graphics::Grid::Role;

# VERSION

use Types::Standard qw(InstanceOf);
use Graphics::Grid::Types qw(:all);

use Graphics::Grid::Unit;

=tmpl attr_x_y

=attr x

A Grahpics::Grid::Unit object specifying x-location.

Default to C<unit(0.5, "npc")>.

=attr y

A Grahpics::Grid::Unit object specifying y-location.

Default to C<unit(0.5, "npc")>.

The reference point is the left-bottom of parent viewport.

=tmpl

=cut

has [qw(x y)] => (
    is      => 'ro',
    isa     => ValueWithUnit,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new(0.5) },
);

1;

__END__

=pod

=head1 DESCRIPTION

This role describes something that has position defined by (x, y).

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::Unit>

