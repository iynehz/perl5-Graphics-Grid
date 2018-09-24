package Graphics::Grid::ViewportLike;

# ABSTRACT: Role for Viewport and ViewportTree

use Graphics::Grid::Role;

# VERSION

use Types::Standard qw(Str);

use Graphics::Grid::Types qw(:all);
use Graphics::Grid::Unit;

=include attr_gp@Graphics::Grid::HasGPar

=cut

=tmpl attr_name

=attr name

A string to uniquely identify the viewport once it has been pushed onto the
viewport tree. If not specified, it would be assigned automatically.

=tmpl

=cut

has name => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => '_build_name',
);

with qw(
  Graphics::Grid::HasGPar
);

method _uid($prefix='GRID.VP') {
    state $idx = 0;
    my $name = "$prefix.$idx";
    $idx++;
    return $name;
}

method _build_name() {
    return $self->_uid('GRID.VP');
}

1;

__END__

=pod

=head1 DESCRIPTION

This module is a role used by Viewport and ViewportTree.

=head1 SEE ALSO

L<Graphics::Grid>

