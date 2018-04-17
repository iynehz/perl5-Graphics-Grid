package Graphics::Grid::Dimensional;

# ABSTRACT: Role for supporting width and height in Graphics::Grid

use Graphics::Grid::Role;

# VERSION

use Types::Standard qw(InstanceOf);
use Graphics::Grid::Types qw(:all);

use Graphics::Grid::Unit;

=tmpl attr_width_height

=attr width

A Grahpics::Grid::Unit object specifying width.

Default to C<unit(1, "npc")>.
    
=attr height

Similar to the C<width> attribute except that it is for height. 

=tmpl
    
=cut

has [qw(width height)] => (
    is      => 'ro',
    isa     => UnitLike,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new(1); },
);

1;

__END__

=pod

=head1 DESCRIPTION

This role describes something that has width and height.

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::Unit>

