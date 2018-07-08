package Graphics::Grid::Grill;

# ABSTRACT: Grill grob

use Graphics::Grid::Class;

# VERSION

use namespace::autoclean;

use Graphics::Grid::GPar;
use Graphics::Grid::Types qw(:all);
use Graphics::Grid::Unit;

=attr h

A unit object indicating the horizontal location of the vertical grill lines.
Default is C<unit([0.25, 0.5, 0.75])>.

=attr v

A unit object indicating the vertical location of the horizontal grill lines.
Default is C<unit([0.25, 0.5, 0.75])>.

=cut

has [qw(h v)] => (
    is      => 'ro',
    isa     => UnitLike,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new( [ 0.25, 0.5, 0.75 ] ); },
);

=include attr_gp@Graphics::Grid::HasGPar

Default is C<gpar(col =E<gt> "grey")>.

=include attr_vp@Graphics::Grid::Grob

=cut

with qw(
  Graphics::Grid::Grob
);

has '+gp' => ( default => sub { Graphics::Grid::GPar->new( col => "grey" ) }, );

method _build_elems () { 1; }

method draw ($driver) {
    my $make_line_unit = fun($h_or_v, $idx) {
        my $u = $h_or_v->at($idx);
        return Graphics::Grid::Unit->new([($u->value->[0]) x 2], $u->unit->[0]);
    };

    my @lines = (
        (
            map {
                Graphics::Grid::Grob::Lines->new(
                    x  => [ 0,  1 ],
                    y  => $make_line_unit->($self->h, $_),
                    gp => $self->gp,
                  )
            } ( 0 .. $self->h->elems - 1 )
        ),
        (
            map {
                Graphics::Grid::Grob::Lines->new(
                    x  => $make_line_unit->($self->v, $_),
                    y  => [ 0,  1 ],
                    gp => $self->gp,
                  )
            } ( 0 .. $self->v->elems - 1 )
        ),
    );

    for (@lines) {
        $_->draw($driver);
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grill;
    use Graphics::Grid::GPar;
    my $rect = Graphics::Grid::Grill->new(
            h => unit([0.25, 0.5, 0.75]),
            v => unit([0.25, 0.5, 0.75]),
            gp => Graphics::Grid::GPar->new(col => "grey"));

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $rect = grill(%params);

=head1 DESCRIPTION

This class represents a grill graphical object.    

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

