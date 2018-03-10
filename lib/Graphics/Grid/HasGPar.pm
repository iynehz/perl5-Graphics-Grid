package Graphics::Grid::HasGPar;

# ABSTRACT: Role for graphics parameters (gpar) in Graphics::Grid

use Graphics::Grid::Role;

# VERSION

use Graphics::Grid::GPar;
use Graphics::Grid::Types qw(:all);

=tmpl attr_gp

=attr gp

An object of Graphics::Grid::GPar. Default is an empty gpar object.

=tmpl

=cut


has gp => (
    is  => 'ro',
    isa => GPar,
    coerce => 1,
    default => sub { Graphics::Grid::GPar->new() },
);

1;

__END__

=head1 DESCRIPTION

This role describes something that has the graphical parameters.

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::GPar>
