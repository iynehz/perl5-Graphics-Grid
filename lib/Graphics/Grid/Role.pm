package Graphics::Grid::Role;

# ABSTRACT: For creating roles in Graphics::Grid

use Graphics::Grid::Setup ();

# VERSION

sub import {
    my ( $class, @tags ) = @_;
    Graphics::Grid::Setup->_import( scalar(caller), qw(:role), @tags );
}

1;

__END__

=pod

=head1 SYNOPSIS
    
    use Graphics::Grid::Role;

=head1 DESCRIPTION

C<use Graphics::Grid::Role> is equivalent of 

    use Graphics::Grid::Setup qw(:role), ...;

=head1 SEE ALSO

L<Graphics::Grid::Setup>

