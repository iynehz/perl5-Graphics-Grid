package Graphics::Grid::Grob::Zero;

# ABSTRACT: Empty grob with minimal size

use Graphics::Grid::Class;

with qw(
  Graphics::Grid::Grob
);

# VERSION

method _build_elems() { 0 }

method draw($driver) { }

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

