package Graphics::Grid::Grob::Null;

# ABSTRACT: Empty grob

use Graphics::Grid::Class;

# VERSION

use Graphics::Grid::Extents;
use Graphics::Grid::Unit;

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

method _build_elems () { 0 }

method _draw ($grid) { }

method extents ($grid) {
    my $zero = Graphics::Grid::Unit->new(0, 'cm');
    return Graphics::Grid::Extents->new(
        x      => $zero,
        y      => $zero,
        width  => $zero,
        height => $zero,
    );
}

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

