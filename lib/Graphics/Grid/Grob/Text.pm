package Graphics::Grid::Grob::Text;

# ABSTRACT: Text grob

use Graphics::Grid::Class;
use MooseX::HasDefaults::RO;

# VERSION

use Types::Standard qw(Str ArrayRef Bool Num);

use Graphics::Grid::Types qw(:all);
use Graphics::Grid::Unit;

has label => (
    isa      => ( ArrayRef [Str] )->plus_coercions(ArrayRefFromValue),
    coerce   => 1,
    required => 1,
);
has rot => (
    isa    => ( ArrayRef [Num] )->plus_coercions(ArrayRefFromValue),
    coerce => 1
);

#has check_overlap => ( is => 'ro', isa => Bool, default => 0 );

with qw(
  Graphics::Grid::Grob
  Graphics::Grid::Positional
  Graphics::Grid::Justifiable
);

method _build_elems() {
    return scalar( @{ $self->label } );
}

method draw($driver) {
    $driver->draw_text($self);
}

1;
