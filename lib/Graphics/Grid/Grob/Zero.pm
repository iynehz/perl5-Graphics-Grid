package Graphics::Grid::Grob::Zero;

# ABSTRACT: Empty grob with minimal size

use Graphics::Grid::Class;

# VERSION

use namespace::autoclean;

use Graphics::Grid::Extents;
use Graphics::Grid::Unit;

with qw(
  Graphics::Grid::Grob
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

    use Graphics::Grid::Grob::Zero;
    my $grob = Graphics::Grid::Grob::Zero->new();

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $grob = zero_grob();

=head1 DESCRIPTION

A "zero" grob is even simpler than a "null" grob.

=head1 SEE ALSO

L<Graphics::Grid::Grob>

