package Graphics::Grid::Driver;

# ABSTRACT: Role for Graphics::Grid driver implementations

use Graphics::Grid::Role;

# VERSION

use List::AllUtils qw(reduce);
use Types::Standard qw(Enum Str InstanceOf Num);

use Graphics::Grid::GPar;
use Graphics::Grid::Util qw(dots_to_cm);

=attr grid

L<Graphics::Grid> object.
Usually this attribute is set by the grid object when it creates or sets
the driver object.

=cut

has grid => (
    is            => 'rw',
    weak_ref      => 1,
    lazy_required => 1,
);

=attr width

Width of the device, in resolution dots.

Default is 1000.

=attr height

Height of the device, in resolution dots.

Default is 1000.

=cut

has [ 'width', 'height' ] => (
    is      => 'rw',
    isa     => Num,
    default => 1000,
);

=attr dpi

=cut 

has dpi => (
    is      => 'rw',
    isa     => Num,
    default => 96
);

=attr current_vptree

=cut

has current_vptree => (
    is      => 'rw',
    isa     => InstanceOf ['Graphics::Grid::ViewportTree'],
    trigger => sub {
        my $self = shift;
        $self->_set_vptree(@_);
    },
    init_arg => undef,
);

has [qw(_current_vp_width_cm _current_vp_height_cm)] =>
  ( is => 'rw', init_arg => undef );

=attr current_gp

=cut

has current_gp => (
    is       => 'rw',
    isa      => InstanceOf ['Graphics::Grid::GPar'],
    default  => sub { $_[0]->default_gpar },
    init_arg => undef,
);

# driver specific 
sub _set_vptree { }

requires 'data';
requires 'write';

requires 'draw_circle';
requires 'draw_points';
requires 'draw_polygon';
requires 'draw_polyline';
requires 'draw_rect';
requires 'draw_segments';
requires 'draw_text';

=classmethod default_gpar()

=cut

classmethod default_gpar() {
    state $gp;
    unless ($gp) {
        $gp = Graphics::Grid::GPar->new(
            col        => "black",
            fill       => "white",
            alpha      => 1,
            lty        => "solid",
            lwd        => 1,
            lineend    => 'round',
            linejoin   => 'round',
            linemitre  => 1,
            fontface   => 'plain',
            fontfamily => "sans",
            fontsize   => 11,
            lineheight => 1.2,
            lex        => 1,
            cex        => 1,
        );
    }
    return $gp;
}

method current_vp_width() {
    return $self->_current_vp_width_cm;
}

method current_vp_height() {
    return $self->_current_vp_height_cm;
}

method _transform_width_to_cm(
    $unitlike, $idx,
    $gp        = $self->current_gp,
    $length_cm = $self->current_vp_width
  )
{
    return $unitlike->transform_to_cm( $self->grid, $idx, $gp, $length_cm );
}

method _transform_height_to_cm(
    $unitlike, $idx,
    $gp        = $self->current_gp,
    $length_cm = $self->current_vp_height
  )
{
    return $unitlike->transform_to_cm( $self->grid, $idx, $gp, $length_cm );
}

1;

__END__

=pod

=head1 SEE ALSO

L<Graphics::Grid>

