package Graphics::Grid::Driver;

# ABSTRACT: Role for Graphics::Grid driver implementations

use Graphics::Grid::Role;

# VERSION

use List::AllUtils qw(reduce);
use Types::Standard qw(Enum Str InstanceOf Num);

use Graphics::Grid::GPar;

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

sub _set_vptree { }

requires 'data';

requires 'draw_circle';
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

method _get_effective_gp($grob) {
    my $path         = $self->current_vptree->path_from_root;
    my @path_to_root = reverse @$path;
    my $merged_gp = reduce { $a->merge($b) } $grob->gp,
      ( map { $_->gp } @path_to_root );
    return $merged_gp;
}
 
1;

__END__

=pod
