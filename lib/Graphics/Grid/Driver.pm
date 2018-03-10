package Graphics::Grid::Driver;

# ABSTRACT: Role for Graphics::Grid driver implementations

use Graphics::Grid::Role;

# VERSION

use List::AllUtils qw(reduce);
use Types::Standard qw(Enum Str InstanceOf Num);

use Graphics::Grid::GPar;
use Graphics::Grid::Util qw(points_to_cm);

has [ 'width', 'height' ] => (
    is       => 'rw',
    isa      => Num,
    required => 1
);
has dpi => (
    is      => 'rw',
    isa     => Num,
    default => 96
);

has current_vptree => (
    is      => 'rw',
    isa     => InstanceOf ['Graphics::Grid::ViewportTree'],
    trigger => sub {
        my $self = shift;
        $self->_set_vptree(@_);
    },
);

has [ 'current_vp_width_cm', 'current_vp_height_cm' ] => (
    is  => 'rw',
    isa => Num,
);

has current_gp => (
    is => 'rw',
    isa => InstanceOf['Graphics::Grid::GPar'],
);

sub _set_vptree { }

requires 'data';
requires 'write';

requires 'draw_circle';
requires 'draw_points';
requires 'draw_polygon';
requires 'draw_polyline';
requires 'draw_rect';
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

my @gp_stack;

method push_gp($gp) {
    push @gp_stack, $gp;
}

method pop_gp() {
    pop @{$self->gp_stack};
}

method _get_effective_gp($grob) {
    return $self->gp;
}

method _transform_width_to_cm(
    $unit, $idx, $gp,
    $vp_width_cm  = $self->current_vp_width_cm,
    $vp_height_cm = $self->current_vp_height_cm
  )
{
    return $self->_transform_to_cm( $unit, $idx, $gp, $vp_width_cm );
}

method _transform_height_to_cm(
    $unit, $idx, $gp,
    $vp_width_cm  = $self->current_vp_width_cm,
    $vp_height_cm = $self->current_vp_height_cm
  )
{
    return $self->_transform_to_cm( $unit, $idx, $gp, $vp_height_cm );
}

classmethod _transform_to_cm( $unit, $idx, $gp, $length_cm ) {
    my $value = $unit->value_at($idx);
    my $unit  = $unit->unit_at($idx);

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
