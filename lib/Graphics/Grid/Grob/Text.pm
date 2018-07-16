package Graphics::Grid::Grob::Text;

# ABSTRACT: Text grob

use Graphics::Grid::Class;

# VERSION

use Types::Standard qw(Str ArrayRef Bool Num);
use namespace::autoclean;

use Graphics::Grid::Types qw(:all);
use Graphics::Grid::Unit;

=attr label

A single string or an array ref of strings. If a an array ref of strings is
specified, these multiple strings will be drawn.

=cut

has label => (
    is => 'ro',
    isa      => ( ArrayRef [Str] )->plus_coercions(ArrayRefFromValue),
    coerce   => 1,
    required => 1,
);

=include attr_x_y@Graphics::Grid::Positional

=include attr_just@Graphics::Grid::HasJust

=attr rot

The angle to rotate the text.

=cut

has rot => (
    is => 'ro',
    isa => ( ArrayRef [Num] )->plus_coercions(ArrayRefFromValue),
    coerce => 1,
    default => sub { [0] },
);

#has check_overlap => ( is => 'ro', isa => Bool, default => 0 );

=include attr_gp@Graphics::Grid::HasGPar

=include attr_vp@Graphics::Grid::Grob

=include attr_elems@Graphics::Grid::Grob

For this module C<elems> returns the number of texts in C<label>.

=cut

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
  Graphics::Grid::HasJust
);

method _build_elems() {
    return scalar( @{ $self->label } );
}

method draw($driver) {
    $driver->draw_text($self);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Text;
    use Graphics::Grid::GPar;
    my $text = Graphics::Grid::Grob::Text->new(
            label => "SOMETHING NICE AND BIG",
            x => 0.5, y => 0.5, rot => 45,
            gp => Graphics::Grid::GPar->new(fontsize => 20, col => "grey"));

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $text = text_grob(%params);

=head1 DESCRIPTION

This class represents a text graphical object.

=head1 SEE ALSO

L<Graphics::Grid::Grob>

