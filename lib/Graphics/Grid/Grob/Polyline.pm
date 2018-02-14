package Graphics::Grid::Grob::Polyline;

# ABSTRACT: Polyline grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

use List::AllUtils qw(uniq);
use Types::Standard qw(ArrayRef Int);

use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

has id => ( isa => ArrayRef [Int] );

has arrow => ( isa => ArrayRef );

has _points_by_idx => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build__points_by_idx',
    init_arg => undef
);

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

has [qw(+x +y)] => (
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new( [ 0, 1 ] ) }
);

method _build_elems() {
    unless ( $self->has_id ) {
        return 1;
    }
    return scalar( uniq( @{ $self->id } ) );
}

method _build__points_by_idx() {
    if ( !$self->has_id ) {
        my @points = map { [ $self->x->at($_), $self->y->at($_) ] }
          ( 0 .. $self->x->elems - 1 );
        return { 0 => \@points };
    }
    else {
        my %points_by_id;
        for my $i ( 0 .. $self->x->elems - 1 ) {
            my $id = $self->id->[$i];
            $points_by_id{$id} //= [];
            push @{ $points_by_id{$id} },
              [ $self->x->at($i), $self->y->at($i) ];
        }

        my @ids_sorted = sort keys %points_by_id;
        my %points_by_idx =
          map { $_ => $points_by_id{ $ids_sorted[$_] } } ( 0 .. $#ids_sorted );
        return \%points_by_idx;
    }
}

method _has_param($name) {
    my $val = $self->$name;
    return ( defined $val and @{$val} > 0 );
}

for my $name (qw(id arrow)) {
    no strict 'refs';    ## no critic
    *{ "has_" . $name } = sub { $_[0]->_has_param($name); }
}

method validate() {
    my $x_size = $self->x->elems;
    my $y_size = $self->y->elems;
    unless ( $x_size == $y_size ) {
        die "'x' and 'y' must have the same length";
    }
    if ( $self->has_id and $x_size != scalar( @{ $self->id } ) ) {
        die "'x', 'y' and 'id' must have the same length";
    }
}

method get_points($idx) {
    my $points_by_idx = $self->_points_by_idx;
    return $points_by_idx->{$idx};
}

method draw($driver) {
    $driver->draw_polyline($self);
}

__PACKAGE__->meta->make_immutable;

1;


__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Grob::Polyline;
    use Graphics::Grid::GPar;

    my $polyline = Graphics::Grid::Grob::Polyline->new(
            x => [
                ( map { $_ / 10 } ( 0 .. 4 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5
            ],
            y => [
                (0.5) x 5,
                ( map { $_ / 10 } reverse( 6 .. 10 ) ),
                (0.5) x 5,
                ( map { $_ / 10 } ( 0 .. 4 ) ),
            ],
            id => [ ( 1 .. 5 ) x 4 ],
            gp => Graphics::Grid::GPar->new(
                col => [qw(black red green3 blue cyan)],
                lwd => 3,
            )
    );

=head1 DESCRIPTION

This class represents a polyline graphical object.

=head1 CONSTRUCTOR

=head1 SEE ALSO

L<Graphics::Grid::Functions>

L<Graphics::Grid::Grob>

