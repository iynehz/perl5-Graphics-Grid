package Graphics::Grid::UnitList;

# ABSTRACT: List of UnitLikes

use Graphics::Grid::Class;

# VERSION

use List::AllUtils;
use Scalar::Util qw(looks_like_number);
use Type::Params ();
use Types::Standard qw(Str ArrayRef Any Num Maybe);

use Graphics::Grid::Util qw(points_to_cm);
use Graphics::Grid::Types qw(:all);

extends 'Forest::Tree';

has _list => ( is => 'ro', default => sub { [] } );

=include attr_elems@Graphics::Grid::UnitLike

=cut

has elems =>
  ( is => 'ro', lazy => 1, builder => '_build_elems', init_arg => undef );

method _build_elems () {
    return List::AllUtils::sum( map { $_->elems } @{ $self->_list } );
}

has is_null_unit => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_is_null_unit',
    init_arg => undef
);

method _build_is_null_unit () {
    return ( List::AllUtils::all { $_->is_null_unit } @{ $self->_list } );
}

with qw(
  Graphics::Grid::UnitLike
);

around BUILDARGS( $orig, $class : UnitLike @rest ) {

    # unfold if an element is already a UnitList.
    my @list = map { $_->$_isa($class) ? @{ $_->_list } : $_ } @rest;
    $class->$orig( _list => \@list );
}

=method at($idx)

=cut

=include methods@Graphics::Grid::UnitLike

=cut

method slice ($indices) {
    my $class = ref($self);
    return $class->new( map { $self->at($_) } @$indices );
}

method at ($idx) {
    $idx %= $self->elems;

    for my $u ( @{ $self->_list } ) {
        my $l = $u->elems;
        if ( $idx < $l ) {
            return $u->at($idx);
        }
        $idx -= $l;
    }
}

method string () {
    return join( ", ", map { $_->string } @{ $self->_list } );
}

method _make_operation ( $op, $other, $swap = undef ) {
    my $class = ref($self);
    return $class->new(
        map { $self->at($_)->_make_operation( $op, $other->at($_) ) }
          ( 0 .. $self->elems - 1 ) );
}

method transform_to_cm($grid, $idx, $gp, $length_cm) {
    return $self->at($_)->transform_to_cm($grid, $idx, $gp, $length_cm);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::UnitList;
    my $ul1 = Graphics::Grid::UnitList->new($u1, $u2, ...);
    
=head1 DESCRIPTION

You would mostly never directly use this class. Usually you could
get a UnitList object by the C<append> method.

    # at least one of $u1 and $u2 is a UnitArithmetic object
    my $ul2 = $u1->append($u2);

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::UnitLike>

