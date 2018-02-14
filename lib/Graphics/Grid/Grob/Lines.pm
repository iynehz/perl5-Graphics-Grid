package Graphics::Grid::Grob::Lines;

# ABSTRACT: Lines grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

extends qw(Graphics::Grid::Grob::Polyline);

use Types::Standard qw(ArrayRef Int);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

# disable "id" attr
has '+id' => ( is => 'ro', init_arg => undef );

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Lines;
    my $lines = Graphics::Grid::Grob::Lines->new(
            x => [ 0, 0.5, 1, 0.5 ],
            y => [ 0.5, 1, 0.5, 0 ],
            gp => Graphics::Grid::GPar->new()
    );

=head1 DESCRIPTION

This class represents a lines graphical object. 

=head1 CONSTRUCTOR

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

