package Graphics::Grid::Class;

# ABSTRACT: For creating classes in Graphics::Grid

use Graphics::Grid::Setup ();

# VERSION

sub import {
    my ( $class, @tags ) = @_;
    Graphics::Grid::Setup->_import( scalar(caller), qw(:class), @tags );
}

1;

__END__

=pod

=head1 SYNOPSIS
    
    use Graphics::Grid::Class;

=head1 DESCRIPTION

C<use Graphics::Grid::Class ...;> is equivalent of 

    use Graphics::Grid::Setup qw(:class), ...;

=head1 SEE ALSO

L<Graphics::Grid::Setup>

