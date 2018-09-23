package Graphics::Grid::UnitArithmetic;

# ABSTRACT: Expression created from Graphics::Grid::Unit objects

use Graphics::Grid::Class;

# VERSION

use Scalar::Util qw(looks_like_number);
use Type::Params ();
use Types::Standard qw(Str ArrayRef Any Num Maybe);
use namespace::autoclean;

use Graphics::Grid::Types qw(:all);

extends 'Forest::Tree';

=attr node

It can be one of the followings,

=over 4

=item * 

A number or an array ref of numbers. If a single number is given it
will be coerced to an array ref that contains the number. This is
used for operands of multiplications.

=item * 

One of C<"+">, C<"-">, C<"*">. In this case the C<children> attr
should contain the operands.

=item *

A Graphics::Grid::Unit object. This is used for operands of plus
and minus.

=back

=cut

has '+node' => (
    isa => (
        ( ArrayRef [Num] )->plus_coercions( Num, sub { [$_] } ) |
          Str->where( sub { $_ =~ /^[\*\+\-]$/ } ) | Unit
    ),
    coerce => 1,
);

=attr children

When the object represents an arithmetic operation, this C<children>
attribute has the operands.

=cut

has '+children' => (
    isa => ArrayRef [
        UnitArithmetic->plus_coercions( Any,
            sub {
                if ( $_->$_isa('Graphics::Grid::UnitArithmetic') ) {
                    return $_;
                }
                my $node = $_;
                unless ( $_->$_isa('Graphics::Grid::Unit')
                    or Ref::Util::is_arrayref($node) )
                {
                    $node = [$node];
                }
                return Graphics::Grid::UnitArithmetic->new( node => $node );
            }
        )
    ],
    coerce => 1,
);

=include attr_elems@Graphics::Grid::UnitLike

=cut

method elems() {
    if ( $self->is_unit ) {
        return $self->node->elems;
    }
    elsif ( $self->is_arithmetic ) {
        return List::AllUtils::max( map { $_->elems } @{ $self->children } );
    }
    else {
        return scalar( @{ $self->node } );
    }
}

method is_null_unit() {
    if ( $self->is_unit ) {
        return $self->node->is_null_unit;
    }
    elsif ( $self->is_arithmetic ) {
        return List::AllUtils::all { $_->is_null_unit } @{ $self->children };
    }
    else {
        return true;
    }
}

with qw(
  Graphics::Grid::UnitLike
);

=method at($idx)

This method returns an object of the same Graphics::Grid::UnitArithmetic class.
The returned object represents the data at given index, and has at only one
value at each node. 

    # $ua1 has 3 elems: 1cm+0.5npc, 2cm+0.5npc, 3cm+0.5npc
    my $ua1 = Graphics::Grid::UnitArithmetic->new(
        node     => '+',
        children => [
            Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ),
            Graphics::Grid::Unit->new(0.5),
        ],
    );

    # $ua2 has only 2cm+0.5npc
    my $ua2 = $u1->at(1);

C<$idx> is applied like wrap-indexing. So below is same as above.

    my $ua3 = $ua1->at(4);

=cut

method at($idx) {
    return $self->slice( [$idx] );
}

method slice($indices) {
    my $class = ref($self);
    if ( $self->is_unit ) {
        return $class->new( node => $self->node->slice($indices) );
    }
    elsif ( $self->is_number ) {
        return $class->new(
            node => [ @{ $self->node }[ map { $_ % $self->elems } @$indices ] ]
        );
    }
    else {
        my @new_indices = map { $_ % $self->elems } @$indices;
        return $class->new(
            node => $self->node,
            children =>
              [ map { $_->slice( \@new_indices ) } @{ $self->children } ]
        );
    }
}

=include methods@Graphics::Grid::UnitLike

=cut

method string() {
    if ( $self->is_unit ) {
        return $self->node->string;
    }
    elsif ( $self->is_number ) {
        return join( ', ', @{ $self->node } );
    }
    else {
        return join(
            ', ',
            map {
                my $left  = $self->children->[0]->at($_);
                my $right = $self->children->[1]->at($_);
                my $format;
                if ( $self->node eq '*' ) {

                    # Swap number to left, to be in accordance with R 'grid'
                    #  library.
                    if ( $right->is_number ) {
                        ( $left, $right ) = ( $right, $left );
                    }
                    if ( $right->is_arithmetic and $right->node ne '*' ) {
                        $format = "%s%s(%s)";
                    }
                }
                $format //= "%s%s%s";
                sprintf( $format, $left->string, $self->node, $right->string );
            } ( 0 .. $self->elems - 1 )
        );
    }
}

method _make_operation( $op, $other, $swap = undef ) {
    if ( $other->$_isa('Graphics::Grid::UnitList') ) {
        require Graphics::Grid::UnitList;
        return $other->_make_operation( $op, $self, !$swap );
    }

    my $class = ref($self);
    return $class->new(
        node     => $op,
        children => ( $swap ? [ $other, $self ] : [ $self, $other ] )
    );
}

=method is_unit

Checks if the object is a Graphics::Grid::Unit.

=cut

method is_unit() {
    return $self->node->$_isa('Graphics::Grid::Unit');
}

=method is_number

Checks if the object is an array ref of numbers.

=cut

method is_number() {
    return Ref::Util::is_arrayref( $self->node );
}

=method is_arithmetic

Check is the object is an arithmetic operation. It is equivalent
to C<!($obj-E<ge>is_unit() or $obj-E<ge>is_number())>.

=cut

method is_arithmetic() {
    return !( $self->is_unit() or $self->is_number() );
}

method transform_to_cm( $grid, $idx, $gp, $length_cm ) {
    my $driver = $grid->driver;
    if ( $self->is_unit ) {
        return $self->node->transform_to_cm( $grid, $idx, $gp, $length_cm );
    }
    elsif ( $self->is_number ) {
        return $self->node->[ $idx % scalar( @{ $self->node } ) ];
    }
    else {    # is_arithmetic
        my $op = $self->node;
        my ( $left, $right ) =
          map { $_->transform_to_cm( $grid, $idx, $gp, $length_cm ) }
          @{ $self->children };
        if ( $op eq '+' ) {
            return $left + $right;
        }
        elsif ( $op eq '-' ) {
            return $left - $right;
        }
        else {    # *
            return $left * $right;
        }
    }
}

=method reduce()

Try to reduce the tree by evaluating arithmetics.
Returns a new Graphics::Grid::UnitArithmetic or Graphics::Grid::Unit
object.

=cut

method reduce() {
    my $class = ref($self);

    if ( $self->is_unit ) {
        return $self->node;
    }
    elsif ( $self->is_number ) {
        return $self->clone;
    }
    else {
        my ( $left, $right ) = map { $_->reduce; } @{ $self->children };
        if (   $left->$_isa('Graphics::Grid::Arithmetic')
            or $right->$_isa('Graphics::Grid::Arithmetic') )
        {
            return $class->new(
                node     => $self->node,
                children => [ $left, $right ]
            );
        }
        else {
            if ( $self->node eq '*' ) {    # one of the children be unit
                my ( $unit, $number ) =
                  $left->$_isa('Graphics::Grid::Unit')
                  ? ( $left, $right )
                  : ( $right, $left );
                my @value =
                  map {
                    $unit->_value_at($_) *
                      $number->node->[ $_ % @{ $number->node } ]
                  } ( 0 .. List::AllUtils::max( $unit->elems, $number->elems ) -
                      1 );

                return Graphics::Grid::Unit->new( \@value, $unit->unit,
                    $unit->data );
            }
            else {
                if ( $left->is_absolute and $right->is_absolute ) {
                    my @value = map {
                        my $a = $left->_transform_absolute_unit_to_cm($_);
                        my $b = $right->_transform_absolute_unit_to_cm($_);
                        $self->node eq '+' ? $a + $b : $a - $b;
                    } (
                        0 .. List::AllUtils::max( $left->elems, $right->elems )
                          - 1 );
                    return Graphics::Grid::Unit->new( \@value, 'cm' );
                }
                else {
                    return $class->new(
                        node     => $self->node,
                        children => [ $left, $right ]
                    );
                }
            }
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::UnitArithmetic;
    use Graphics::Grid::Unit;

    my $ua1 = Graphics::Grid::UnitArithmetic->new(
        node     => '+',
        children => [
            Graphics::Grid::Unit->new( [ 1, 2, 3 ], "cm" ),
            Graphics::Grid::Unit->new(0.5),
        ],
    );
    my $ua2 = Graphics::Grid::UnitArithmetic->new(
        Graphics::Grid::Unit->new(0.1, "npc")
    );
    my $ua3 = $ua1 - $ua2;
    my $ua4 = $ua1 * 2;

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $ua = unit(2, 'inches') * 2;
    
=head1 DESCRIPTION

You would mostly never directly use this class. See
L<Graphics::Grid::Unit> for unit arithmetic on unit objects.

This class Graphics::Grid::UnitArithmetic represents arithmetic on
Graphics::Grid::Unit objects. It provides a way to create a unit-like
value that combines both relative and absolute values.

Supported operators are C<+>, C<->, and C<*>. A plus or minus
operation requires both its binary operands are consumers of 
Graphics::Grid::UnitLike. The multiply operation requires one of
its operands is consumer of L<Graphics::Grid::UnitLike>, the other
a number or array ref of numbers.

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::UnitLike>

L<Graphics::Grid::Unit>

L<Forest::Tree>

