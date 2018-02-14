package Graphics::Grid::Grob::Points;

# ABSTRACT: Points grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION


use Graphics::Grid::Unit;
use Graphics::Grid::Types qw(:all);

has pch => ( isa => PointSymbol );
has size => (
    isa     => ValueWithUnit,
    coerce  => 1,
    default => sub { Graphics::Grid::Unit->new( 1, "char" ) }
);

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
);

__PACKAGE__->meta->make_immutable;

1;
