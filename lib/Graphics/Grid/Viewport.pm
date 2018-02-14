package Graphics::Grid::Viewport;

# ABSTRACT: Viewport

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

with qw(
  Graphics::Grid::Positional
  Graphics::Grid::Dimensional
  Graphics::Grid::Justifiable
  Graphics::Grid::HasGPar
);

use Types::Standard qw(Num Str ArrayRef HashRef);
use namespace::autoclean;

use Graphics::Grid::Types qw(:all);
use Graphics::Grid::Unit;

my $Range = ( ArrayRef [Num] )->where( sub { @$_ == 2 } );

has default_units => (
    isa     => Str,
    default => 'npc',
);

# TODO
has clip => (
    isa     => Clip,
    default => 'inherit',
);

has [ "xscale", "yscale" ] => (
    isa     => $Range,
    default => sub { [ 0, 1 ] },
);

# anti-clockwise
has angle => ( isa => Num, default => 0, );

has layout         => ( );
has layout_pos_row => ( );
has layout_pos_col => ( );

has uid => (
    default => sub {
        state $idx = 0;
        my $name = "GRID.VP.$idx";
        $idx++;
        return $name;
    },
    init_arg => undef
);

has name => (
    isa     => Str,
    lazy => 1,
    builder => '_build_name',
);

sub _build_name { $_[0]->uid; }

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

=head1 DESCRIPTION

A viewport describes on a graphics device a rectangular region within
which a coordinate system is defined.

=head1 SEE ALSO

L<Graphics::Grid>

