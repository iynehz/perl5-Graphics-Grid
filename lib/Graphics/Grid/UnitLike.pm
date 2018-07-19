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

=tmpl method_string

=method string

Returns a string representing the object.

=tmpl

=cut

requires 'string';

=tmpl method_sum

=method sum

Sum the effective unit vector in a unit object.

=tmpl

=cut

method sum() {
    return reduce { $a + $b } map { $self->at($_) } (0 .. $self->elems - 1);
}

1;

__END__

=head1 DESCRIPTION

This role describes something that can be used as unit-value.

=head1 SEE ALSO

L<Graphics::Grid>

