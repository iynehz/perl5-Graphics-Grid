package Graphics::Grid::Grob::Zero;

# ABSTRACT: Empty grob

use Graphics::Grid::Class;

with qw(Graphics::Grid::Grob);

# VERSION

method _build_elems() { 0 }

method draw($driver) { } 

1;
