package Graphics::Grid::Unit;

# ABSTRACT: A vector of unit values

use Graphics::Grid::Class;

# VERSION

use Type::Params ();
use Types::Standard qw(Str ArrayRef Value Num);
use namespace::autoclean;

use Graphics::Grid::Util qw(points_to_cm);
use Graphics::Grid::Types qw(:all);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my %params;
    if ( @_ == 1 ) {
        if ( ref( $_[0] ) ne 'HASH' ) {
            return $class->$orig( value => $_[0] );
        }
    }
    return $class->$orig(@_);
};

=attr value

Array ref of numbers.

=cut

has value => (
    is       => 'ro',
    isa      => ( ArrayRef [Num] )->plus_coercions( Num, sub { [$_] } ),
    coerce   => 1,
    required => 1,
);

=attr unit

Array ref of units.

Possible units are:

=over 4

=item *

npc

Normalised Parent Coordinates (the default). The origin of the viewport is
(0, 0) and the viewport has a width and height of 1 unit. For example,
(0.5, 0.5) is the centre of the viewport.

=item *

cm

Centimeters.

=item *

inches

Inches. 1 in = 2.54 cm.

=item *

mm

Millimeters. 10 mm = 1 cm.

=item *

points

Points. 72.27 pt = 1 in.

=item *

picas

Picas. 1 pc = 12 pt.

=back

=cut

has unit => (
    is => 'ro',
    isa =>
      ( ArrayRef [Unit] )->plus_coercions( Str, sub { [ Unit->coerce($_) ] } ),
    coerce  => 1,
    default => sub { ['npc'] },
);

=method elems()

Get the number of effective values in the object.

=cut

method elems() {
    return scalar( @{ $self->value } );
}

=method value_at($idx)

Get value at given index. C<$idx> is applied like wrap-indexing.
    
=cut

method value_at($idx) {
    return $self->value->[ $idx % scalar( @{ $self->value } ) ];
}

=method unit_at($idx)

Get unit at given index. C<$idx> is applied like wrap-indexing.

=cut

method unit_at($idx) {
    return $self->unit->[ $idx % scalar( @{ $self->unit } ) ];
}

=method at($idx)

This method returns an object of the same Graphics::Grid::Unit class.
The returned object represents the value and unit at given index, and has
at only one value and one unit.

    my $u1 = Graphics::Grid::Unit->new(value => [2,3,4], unit => "npc");

    # $u2 is same as Graphics::Grid::GPar->new(value => 3, unit => "npc");
    my $u2 = $u1->at(1);

C<$idx> is applied like wrap-indexing. So below are same as above.

    my $u3 = $u1->at(4);
    my $u4 = $u2->at(42);

=cut

method at($idx) {
    return ref($self)->new(
        value => $self->value_at($idx),
        unit  => $self->unit_at($idx)
    );
}

method stringify() {
    local $Data::Dumper::Indent = 0;
    return Dumper( $self->value ) . ' x ' . Dumper( $self->unit );
}

=method as_cm($absolute_cm)

This method returns a new Graphics::Grid::Unit object which has all its
values converted to centimeter. The C<$absolute_cm> parameter tells
it how to convert from C<npc> to C<cm>.

    my $u = Grahpics::Grid::Unit->new(0.42);

    # $u_in_cm is same as Graphics::Grid::Unit->new(42, "cm");
    my $u_in_cm = $u->as_cm(100);
    
=cut

method as_cm($abs_cm) {
    my @values = map {
        my $value = $self->value_at($_);
        my $unit  = $self->unit_at($_);

        if ( $unit eq 'npc' ) {
            $value * $abs_cm;
        }
        elsif ( $unit eq 'cm' ) {
            $value;
        }
        elsif ( $unit eq 'inches' ) {
            $value * 2.54;
        }
        elsif ( $unit eq 'mm' ) {
            $value / 10;
        }
        elsif ( $unit eq 'points' ) {
            points_to_cm($value);
        }
        elsif ( $unit eq 'picas' ) {
            points_to_cm($value) * 12;
        }
        else {
            die "unsupported unit '$unit'";
        }
    } ( 0 .. $self->elems - 1 );
    return ref($self)->new( value => \@values, unit => 'cm' );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Unit;

    my $u1 = Graphics::Grid::Unit->new(42);

    # $u2 is same as $u1
    my $u2 = Graphics::Grid::Unit->new(42, "npc");

    my $u3 = Graphics::Grid::Unit->new([1,2,3], "npc");

    # $u4 is same as $u3
    my $u4 = Graphics::Grid::Unit->new([1,2,3], ["npc", "npc", "npc"]);

=head1 DESCRIPTION

A Graphics::Grid::Unit object is an array ref of unit values. A unit value is
a single numeric value with an associated unit.

=head1 CONSTRUCTOR

The constructor supports multiple forms of parameters. It can coerce
from a single value to array ref. And it allows specifying the values and
units without the C<values> and C<unit> keys.

So below are equivalent,

    Graphics::Grid::Unit->new(42);      # unit defaults to npc
    Graphics::Grid::Unit->new(42, "npc");
    Graphics::Grid::Unit->new([42], ["npc"]);
    Graphics::Grid::Unit->new(values => 42, units => "npc");
    Graphics::Grid::Unit->new(values => [42], units => ["npc"]);

=head1 SEE ALSO

L<Graphics::Grid>

