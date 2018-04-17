package Graphics::Grid::Driver;

# ABSTRACT: Role for Graphics::Grid driver implementations

use Graphics::Grid::Role;

# VERSION

use List::AllUtils qw(reduce);
use Types::Standard qw(Enum Str InstanceOf Num);

use Graphics::Grid::GPar;
use Graphics::Grid::Util qw(points_to_cm);

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
);

has [ '_current_vp_width_cm', '_current_vp_height_cm' ] => ( is => 'rw' );

=attr current_gp

=cut

has current_gp => (
    is  => 'rw',
    isa => InstanceOf ['Graphics::Grid::GPar'],
);

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

sub default_gpar {
    return Graphics::Grid::GPar->new(
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

method _transform_width_to_cm(
    $unitlike, $idx, $gp,
    $vp_width_cm  = $self->_current_vp_width_cm,
    $vp_height_cm = $self->_current_vp_height_cm
  )
{
    return $self->_transform_to_cm( $unitlike, $idx, $gp, $vp_width_cm );
}

method _transform_height_to_cm(
    $unitlike, $idx, $gp,
    $vp_width_cm  = $self->_current_vp_width_cm,
    $vp_height_cm = $self->_current_vp_height_cm
  )
{
    return $self->_transform_to_cm( $unitlike, $idx, $gp, $vp_height_cm );
}

classmethod _transform_to_cm( $unitlike, $idx, $gp, $length_cm ) {
    if ( $unitlike->$_isa('Graphics::Grid::UnitArithmetic') ) {
        return $class->_transform_unitlike_to_cm( $unitlike, $idx, $gp,
            $length_cm );
    }
    else {    # Graphics::Grid::Unit
        return $class->_transform_unit_to_cm( $unitlike, $idx, $gp,
            $length_cm );
    }
}

classmethod _transform_unitlike_to_cm( $unitlike, $idx, $gp, $length_cm ) {
    if ( $unitlike->is_unit ) {
        return $class->_transform_unit_to_cm( $unitlike->node, $idx, $gp,
            $length_cm );
    }
    elsif ( $unitlike->is_number ) {
        return $unitlike->node->[ $idx % scalar( @{ $unitlike->node } ) ];
    }
    else {    # is_arithmetic
        my $op = $unitlike->node;
        my ( $arg0, $arg1 ) = map {
            $class->_transform_unitlike_to_cm( $unitlike->children->[$_],
                $idx, $gp, $length_cm )
        } qw(0 1);
        if ( $op eq '+' ) {
            return $arg0 + $arg1;
        }
        elsif ( $op eq '-' ) {
            return $arg0 - $arg1;
        }
        else {    # *
            return $arg0 * $arg1;
        }
    }
}

classmethod _transform_unit_to_cm( $unit, $idx, $gp, $length_cm ) {
    my $unit_single = $unit->at($idx);
    my $value       = $unit_single->value->[0];
    my $unit        = $unit_single->unit->[0];

    if ( $unit eq 'npc' ) {
        return $value * $length_cm;
    }
    elsif ( $unit eq 'cm' ) {
        return $value;
    }
    elsif ( $unit eq 'inches' ) {
        return $value * 2.54;
    }
    elsif ( $unit eq 'mm' ) {
        return $value / 10;
    }
    elsif ( $unit eq 'points' ) {
        return points_to_cm($value);
    }
    elsif ( $unit eq 'picas' ) {
        return points_to_cm($value) * 12;
    }
    elsif ( $unit eq 'char' ) {
        my $font_size = $gp->at($idx)->fontsize->[0];
        return points_to_cm( $font_size * $value );
    }
    else {
        die "unsupported unit type '$unit'";
    }
}

1;

__END__

=pod

=head1 SEE ALSO

L<Graphics::Grid>

