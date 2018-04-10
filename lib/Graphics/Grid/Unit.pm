package Graphics::Grid::Unit;

# ABSTRACT: A vector of unit values

use Graphics::Grid::Class;

# VERSION

use Scalar::Util qw(looks_like_number);
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
    elsif ( @_ == 2
        and ( ref( $_[0] ) eq 'ARRAY' or looks_like_number( $_[0] ) ) )
    {
        return $class->$orig( value => $_[0], unit => $_[1] );
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

=item *

char

Multiples of nominal font height of the viewport (as specified by the
viewport's C<fontsize>).

=item *

native

Locations and dimensions are relative to the viewport's C<xscale> and
C<yscale>.

=back

=cut

has unit => (
    is => 'ro',
    isa =>
      ( ArrayRef [Unit] )->plus_coercions( Str, sub { [ Unit->coerce($_) ] } ),
    coerce  => 1,
    default => sub { ['npc'] },
);

=method is_absolute_unit($unit_name)

This is a class method. It tells if the given unit name is absolute or not.

    my $is_absolute = Graphics::Grid::Unit->is_absolute_unit('cm');

=cut

classmethod is_absolute_unit($unit_name) {
    state $check = Type::Params::compile(Unit);
    my ($unit_name_coerced) = $check->($unit_name);

    state $absolute_units = { map { $_ => 1 } qw(cm inches mm points picas) };
    return exists( $absolute_units->{$unit_name_coerced} );
}

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
    local $Data::Dumper::Terse = 1;
    return Dumper( $self->value ) . ' x ' . Dumper( $self->unit );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Unit;

    # $u1, $u2, $u3 are same
    my $u1 = Graphics::Grid::Unit->new(42);
    my $u2 = Graphics::Grid::Unit->new(42, "npc");
    my $u3 = Graphics::Grid::Unit->new(value => 42, unit => "npc");

    # $u4, $u5, and $u6 are same
    my $u3 = Graphics::Grid::Unit->new([1,2,3], "npc");
    my $u4 = Graphics::Grid::Unit->new([1,2,3], ["npc", "npc", "npc"]);
    my $u4 = Graphics::Grid::Unit->new(value => [1,2,3], unit => "npc");

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $u = unit(@params);
    
=head1 DESCRIPTION

A Graphics::Grid::Unit object is an array ref of unit values. A unit value is
a single numeric value with an associated unit.

=head1 CONSTRUCTOR

The constructor supports multiple forms of parameters. It can coerce
from a single value to array ref. And it allows specifying the values and
units without the C<value> and C<unit> keys.

So below are all equivalent,

    Graphics::Grid::Unit->new(42);      # unit defaults to npc
    Graphics::Grid::Unit->new([42]); 
    Graphics::Grid::Unit->new(42, "npc");
    Graphics::Grid::Unit->new([42], ["npc"]);
    Graphics::Grid::Unit->new(value => 42);
    Graphics::Grid::Unit->new(value => [42]);
    Graphics::Grid::Unit->new(value => 42, unit => "npc");
    Graphics::Grid::Unit->new(value => [42], unit => ["npc"]);

=head1 SEE ALSO

L<Graphics::Grid>

