package Graphics::Grid::Grob::Lines;

# ABSTRACT: Lines grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

extends qw(Graphics::Grid::Grob::Polyline);

use Types::Standard qw(ArrayRef Int);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

=include attr_x_y@Graphics::Grid::Grob::Polyline

=include attr_gp@Graphics::Grid::HasGPar

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> always returns 1.

=cut

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

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $lines = lines_grob(%params);

=head1 DESCRIPTION

This class represents a "lines" graphical object. It is a subclass of
L<Graphics::Grid::Grob::Polyline>. The difference is that this class
assumes all points are for the same line. 

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

L<Graphics::Grid::Grob::Polyline>

