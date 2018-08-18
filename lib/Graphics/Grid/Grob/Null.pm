package Graphics::Grid::Grob::Null;

# ABSTRACT: Empty grob

use Graphics::Grid::Class;

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

# VERSION

method _build_elems() { 0 }

method _draw($grid) { }

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Null;
    my $grob = Graphics::Grid::Grob::Null->new();

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $grob = null_grob();

=head1 DESCRIPTION

This class represents an null grob which has zero width, zero height, and
draw nothing. It can be used as a place-holder or as an invisible reference
point for other drawing.

=head1 SEE ALSO

L<Graphics::Grid::Grob>

