package Graphics::Grid::Extents;

# ABSTRACT: Grob's extents on the drawing layer

use Graphics::Grid::Class;

# VERSION

use List::AllUtils qw(min max);
use Types::Standard qw(Num);

use Graphics::Grid::Types qw(:all);

=attr x

x of the bottom-left point of the bounding box.

=attr y

y of the bottom-left point of the bounding box.

=attr width

Width of the bounding box.

=attr height

Height of the bounding box.

=cut

has [qw(x y)]          => ( is => 'ro', isa => Unit, required => 1 );
has [qw(width height)] => ( is => 'ro', isa => Unit, required => 1 );

has left   => ( is => 'ro', lazy => 1, builder => '_build_left' );
has bottom => ( is => 'ro', lazy => 1, builder => '_build_bottom' );
has right  => ( is => 'ro', lazy => 1, builder => '_build_right' );
has top    => ( is => 'ro', lazy => 1, builder => '_build_top' );

method _build_left () { $self->x; }
method _build_right () { ($self->x + $self->width)->reduce; }
method _build_bottom () { $self->y; }
method _build_top () { ($self->y + $self->height)->reduce; }

=method merge($other)

Returns a new Graphics::Grid::Extents object.

=cut

method merge ($other) {
    return $self unless defined $other;

    my $to_cm = sub { $_[0]->_transform_absolute_unit_to_cm(0); };
    my $l = min( &$to_cm($self->left), &$to_cm($other->left) );
    my $b = min( &$to_cm($self->bottom), &$to_cm($other->bottom) );
    my $t = max( &$to_cm($self->top), &$to_cm($other->top) );
    my $r = max( &$to_cm($self->right), &$to_cm($other->right) );

    my $class = ref($self);
    return $class->new(
        x      => Graphics::Grid::Unit->new($l, 'cm'),
        y      => Graphics::Grid::Unit->new($b, 'cm'),
        width  => Graphics::Grid::Unit->new($r - $l, 'cm'),
        height => Graphics::Grid::Unit->new($t - $b, 'cm'),
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    my $extents = $grob->extents($grid);

=head1 DESCRIPTION

This class represents a grob's extents (bounding box, etc) on the
drawing layer. Usually its object is obtained by called the
C<extents()> method of a grob object.

=head1 SEE ALSO

L<Graphics::Grid::Grob>

