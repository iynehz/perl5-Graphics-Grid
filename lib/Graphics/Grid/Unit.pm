package Graphics::Grid::Unit;

# ABSTRACT: A vector of unit values

use Graphics::Grid::Class;

# VERSION

use Scalar::Util qw(looks_like_number);
use Type::Params ();
use Types::Standard qw(Str ArrayRef Value Num Maybe);
use namespace::autoclean;

use Graphics::Grid::Types qw(:all);

use overload
  '+'      => 'plus',
  '-'      => 'minus',
  '*'      => 'multiply',
  '=='     => 'equal',
  'eq'     => 'equal',
  fallback => 1;

around BUILDARGS( $orig, $class : @rest ) {
    my %params;
    if ( @rest == 1 ) {
        if ( ref( $rest[0] ) ne 'HASH' ) {
            return $class->$orig( value => $rest[0] );
        }
    }
    elsif ( @rest == 2
        and ( ref( $rest[0] ) eq 'ARRAY' or looks_like_number( $rest[0] ) ) )
    {
        return $class->$orig( value => $rest[0], unit => $rest[1] );
    }
    return $class->$orig(@rest);
}

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

=for :list
* npc
Normalised Parent Coordinates (the default). The origin of the viewport is
(0, 0) and the viewport has a width and height of 1 unit. For example,
(0.5, 0.5) is the centre of the viewport.
* cm
Centimeters.
* inches
Inches. 1 in = 2.54 cm.
* mm
Millimeters. 10 mm = 1 cm.
* points
Points. 72.27 pt = 1 in.
* picas
Picas. 1 pc = 12 pt.
* char
Multiples of nominal font height of the viewport (as specified by the
viewport's C<fontsize>).
* native
Locations and dimensions are relative to the viewport's C<xscale> and
C<yscale>.
* null
Only meaningful for layouts. It indicates what relative fraction of the
available width/height the column/row occupies.

=cut

has unit => (
    is  => 'ro',
    isa => ( ArrayRef [UnitName] )
      ->plus_coercions( Str, sub { [ UnitName->coerce($_) ] } ),
    coerce  => 1,
    default => sub { ['npc'] },
);

with qw(
  Graphics::Grid::UnitLike
);

=include attr_elems@Graphics::Grid::UnitLike

=cut

method elems () {
    return scalar( @{ $self->value } );
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

fun _x_at ($attr) {
    return method($idx) {
        my $x = $self->$attr;
        return $x->[ $idx % scalar( @{$x} ) ];
    };
}
*_value_at = _x_at('value');
*_unit_at  = _x_at('unit');

method slice ($indices) {
    my @value = map { $self->_value_at($_) } @$indices;
    my @unit  = map { $self->_unit_at($_) } @$indices;
    return ref($self)->new( \@value, \@unit );
}

method at ($idx) {
    return $self->slice([$idx]);
}

=classmethod is_absolute_unit($unit_name)

This is a class method. It tells if the given unit name is absolute or not.

    my $is_absolute = Graphics::Grid::Unit->is_absolute_unit('cm');

=cut

classmethod is_absolute_unit ($unit_name) {
    state $check = Type::Params::compile(UnitName);
    my ($unit_name_coerced) = $check->($unit_name);

    state $absolute_units = { map { $_ => 1 } qw(cm inches mm points picas) };
    return exists( $absolute_units->{$unit_name_coerced} );
}

=include methods@Graphics::Grid::UnitLike

=cut

method string () {
    return join(
        ', ',
        map {
            my $u = $self->at($_);
            sprintf( "%s%s", $u->value->[0], $u->unit->[0] );
        } ( 0 .. $self->elems - 1 )
    );
}

method _make_operation ( $op, $other, $swap = undef ) {
    if ( $other->$_isa('Graphics::Grid::UnitList') ) {
        require Graphics::Grid::UnitList;
        return $other->_make_operation( $op, $self, !$swap );
    }

    require Graphics::Grid::UnitArithmetic;
    return Graphics::Grid::UnitArithmetic->new( node => $self )
      ->_make_operation( $op, $other, $swap );
}

method equal ($other, $swap=undef) {
    return false if ( $self->elems != $other->elems );

    return (
        List::AllUtils::all {
            $self->_value_at($_) == $other->_value_at($_)
              and $self->_unit_at($_) eq $other->_unit_at($_)
        }
        ( 0 .. $self->elems - 1 )
    );
}

around append( UnitLike $other) {
    if ( $other->$_isa('Graphics::Grid::Unit') ) {
        my $merge = fun( $attr, $same ) {
            my $attr_at = "_${attr}_at";
            my ( $self_eff_len, $other_eff_len ) =
              map { scalar( @{ $_->$attr } ) } ( $self, $other );

            # for the simplest case, return aref of only one data
            if ( $self_eff_len == 1 and $self_eff_len == $other_eff_len ) {
                my $x = $self->$attr_at(0);
                if ( $same->( $x, $other->$attr_at(0) ) ) {
                    return [$x];
                }
            }
            return [
                ( map { $self->$attr_at($_) }  ( 0 .. $self->elems - 1 ) ),
                ( map { $other->$attr_at($_) } ( 0 .. $other->elems - 1 ) )
            ];
        };

        my $value = $merge->( 'value', sub { $_[0] == $_[1] } );
        my $unit  = $merge->( 'unit',  sub { $_[0] eq $_[1] } );
        return ref($self)->new( $value, $unit );
    }
    else {
        return $self->$orig($other);
    }
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

A Graphics::Grid::Unit object is an array ref of unit values. A unit value
is a single numeric value with an associated unit.

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

=head1 ARITHMETIC

Several arithmetic operations, C<+>, C<->, and C<*>, are supported on
Graphics::Grid::Unit objects.

    use Graphics::Grid::Functions qw(:all);

    # 1cm+0.5npc, 2cm+0.5npc, 3cm+0.5npc
    my $ua1 = unit([1,2,3], "cm") + unit(0.5);

    # 1cm*2, 2cm*2, 3cm*2
    my $ua2 = unit([1,2,3], "cm") * 2;

A plus or minus operation requires both its binary operands are consumers
of Graphics::Grid::UnitLike. The multiply operation requires one of
its operands is consumer of Graphics::Grid::UnitLike, the other
a number or array ref of numbers.

Return value of an operation is an object of
Graphics::Grid::UnitArithmetic.

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::UnitLike>

L<Graphics::Grid::UnitArithmetic>

