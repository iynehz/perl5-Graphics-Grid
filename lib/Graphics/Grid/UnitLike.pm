package Graphics::Grid::UnitLike;

# ABSTRACT: Role for unit-like classes in Graphics::Grid

use Graphics::Grid::Role;

# VERSION

use List::AllUtils qw(reduce);
use namespace::autoclean;

use Graphics::Grid::Types qw(:all);

with qw(MooseX::Clone);

=tmpl attr_elems

=method elems

Number of effective values in the object.

=method length

This is an alias of C<elems()>.

=tmpl

=cut

requires 'elems';

method length() { $self->elems; }

=method at

=cut

requires 'at';

=method stringify

=cut

requires 'stringify';

1;

__END__

=head1 DESCRIPTION

This role describes something that can be used as unit-value.

=head1 SEE ALSO

L<Graphics::Grid>

