package Graphics::Grid::UnitLike;

# ABSTRACT: Role for unit-like classes in Graphics::Grid

use Graphics::Grid::Role;

# VERSION

use List::AllUtils qw(reduce);
use Type::Params;
use Types::Standard qw(ArrayRef Maybe Num);

use Graphics::Grid::Types qw(UnitLike UnitName);

with qw(MooseX::Clone);

use overload
  '+'      => 'plus',
  '-'      => 'minus',
  '*'      => 'multiply',
  fallback => 1;

=tmpl attr_elems

=method elems

Number of effective values in the object.

=method length

This is an alias of C<elems()>.

=tmpl

=cut

requires 'elems';

method length() { $self->elems; }

requires 'is_null_unit';

=method at

=cut

requires 'at';


=tmpl methods

=method slice($indices) 

Slice by indices.

=method string()

Returns a string representing the object.

=method sum()

Sum the effective unit vector in a unit object.

=method append($other)

Append two UnitLike objects. If both are Graphics::Grid::Unit objects,
this method would return a Graphics::Grid::Unit object. Otherwise,
it would return a Graphics::Grid::UnitList object.

=method insert($other, $after=$self->elems-1)

Insert another UnitLike object after index C<$after>.
Insert before first element if C<after> is a negative value.

=tmpl

=cut

requires 'slice';

requires 'string';

method sum() {
    return reduce { $a + $b } map { $self->at($_) } ( 0 .. $self->elems - 1 );
}

method append( UnitLike $other) {
    require Graphics::Grid::UnitList;
    return Graphics::Grid::UnitList->new( $self, $other );
}

method insert( UnitLike $other, $after = $self->elems - 1 ) {
    if ( $after < 0 ) {
        return $other->append($self);
    }
    elsif ( $after >= $self->elems - 1 ) {
        return $self->append($other);
    }
    else {
        my $u1 = $self->slice( [ 0 .. $after ] );
        my $u2 = $self->slice( [ $after + 1 .. $self->elems - 1 ] );
        return $u1->append($other)->append($u2);
    }
}

sub _make_operation { ... }

method plus( Maybe [UnitLike] $other, $swap = undef ) {
    return $self->clone unless ( defined $other );
    return $self->_make_operation( '+', $other, $swap );
}

method minus( Maybe [UnitLike] $other, $swap = undef ) {
    return $self->clone unless ( defined $other );
    return $self->_make_operation( '-', $other, $swap );
}

method multiply( ( ArrayRef [Num] | Num ) $other, $swap = undef ) {
    return $self->_make_operation( '*', $other, $swap );
}

=method transform_to_cm($grid, $idx, $gp, $length_cm)

=cut

requires 'transform_to_cm';

=classmethod is_absolute_unit($unit_name)

This is a class method. It tells if the given unit name is absolute or not.

    my $is_absolute = Graphics::Grid::UnitLike->is_absolute_unit('cm');

=cut

classmethod is_absolute_unit ($unit_name) {
    # cannot put the unit in function signature, as we need coercion.
    state $check = Type::Params::compile(UnitName);
    my ($unit_name_coerced) = $check->($unit_name);

    state $absolute_units = { map { $_ => 1 } qw(cm inches mm points picas) };
    return exists( $absolute_units->{$unit_name_coerced} );
}

1;

__END__

=head1 DESCRIPTION

This role represents something that can be used as unit-value.

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::Unit>

L<Graphics::Grid::UnitArithmetic>

L<Graphics::Grid::UnitList>

