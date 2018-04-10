[![Build Status](https://travis-ci.org/stphnlyd/perl5-Graphics-Grid.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Graphics-Grid)

# NAME

Graphics::Grid - An incomplete port of the R "grid" library to Perl

# VERSION

version 0.0000\_02

# SYNOPSIS

```perl
use Graphics::Grid;
use Graphics::Grid::GPar;
use Graphics::Grid::Viewport;

my $grid = Graphics::Grid->new();
$grid->push_viewport(
        Graphics::Grid::Viewport->new(width => 0.5, height => 0.5));

$grid->rect(gp => Graphics::Grid::GPar->new(col => 'blue'));
```

# DESCRIPTION

This is alpha code. Before version 1.0 of this library, its API would change
without any notice.

This library is an incomplete port of Paul Murrell's R "grid" library. The R
"grid" library is a low level graphics system that provides full access to
the graphics facilities in R. It's used by some other R plotting libraries
including the famous "ggplot2". 

With my (immature maybe) understanding the fundamental designs and features
of the R "grid" library can be summarized as following:

- It supports a few graphical primitives (called "grob") like lines,
rectangles, circles, text, etc. And they can be configured via a set
of graphical parameters (called "gpar"), like colors, line weights and
types, fonts, etc. And, it also has a tree structure called "gTree"
which allows arranging the grobs in a hierachical way.
- It designs something called "viewport" which is basically an arbitrary
rectangular region which defines the transform (position, coordinate scale,
rotation) on the graphics device. There is a global viewport stack 
(actually it's a tree). Viewports can be pushed onto, or popped from the
stack, and drawing always takes place on the "top" or "current" viewport.
Thus for drawing each graphical primitive it's possible to have a specific
transform for the graphics device context. Combined with its ability to
define graphical primitives as mention above, the "grid" library enables
the full possibilities of customization which cannot be done with R's
standard "plot" system.
- It has a "unit" system. a "unit" is basically a numerical value plus a
unit. The default unit is "npc" (Normalised Parent Coordinates), which
describes an object's position or dimension relative to those of the parent
viewport. So when defining a grob, for example a rectangle, usually you do
not specify its (x, y) position or width or height in absolute values,
instead you specify its relative position, and width and height in ratio
to the viewport on which the rectangle is drawn. Beause of this design,
it's easy to adapt a plot to various types and sizes of graphics devices. 
- Similar to many stuffs in the R world, parameters to the R "grid" library
are vectorized. This means a single rectangular "grob" object can actually
contain information for multiple rectangles. 
- It has a grid-based layout system. That's probably why the library got the
name "grid".

The target of this Perl Graphics::Grid library, as of today, is to have
most of the R "grid"'s fundamental features mentioned above except for
the grid-layout system. 

This Graphics::Grid module is the object interface of this libray. There is
also a function interface [Graphics::Grid::Functions](https://metacpan.org/pod/Graphics::Grid::Functions), which is more like
the interface of the R "grid" library.

# ATTRIBUTES

## driver

Set the device driver. The value needs to be a consumer of the [Graphics::Grid::Driver](https://metacpan.org/pod/Graphics::Grid::Driver)
role. Default is a [Graphics::Grid::Driver::Cairo](https://metacpan.org/pod/Graphics::Grid::Driver::Cairo) object.

# METHODS

## current\_vptree($all=true)

If `$all` is a true value, it returns the whole viewport tree, whose root
node contains the "ROOT" viewport. If `$all` is a false value, it returns
the current viewport tree, whose root node contains the current viewport.

## current\_viewport()

Get the current viewport. It's same as,

```
$grid->current_vptree(0)->node;
```

## push\_viewport(@viewports)

Push viewports onto the global viewport tree, and update the
current viewport.

## pop\_viewport($n=1)

Remove `$n` levels of viewports from the global viewport tree,
and update to current viewport to the remaining parent node of the
removed part of tree nodes.

if `$n` is 0 then only the "ROOT" node of the global viewport
tree would be retained and set to current. 

## up\_viewport($n=1)

This is similar to the `pop_viewport` method except that it does
not remove the tree nodes, but only updates the current viewport. 

## down\_viewport($from\_tree\_node, $name)

Start from a tree node, and try to find the first child node whose
name is `$name`. If found it sets the node to current, and returns
the number of tree leves it went down. So it's possible to do
something like,

```perl
my $depth = downViewport(...);
upViewport($depth).
```

`$name` can also be an array ref of names which defines a "path".
In this case the top-most node in the "path" is set to current.

## seek\_viewport($from\_tree, $name)

This is similar to the `down_viewport` method except that this always
starts from the "ROOT" node.

## draw($grob)

Draw a grob (or gtree) on the graphics device.

## ${grob\_type}(%params)

This creates a grob and draws it. For example, `rect(%params)` would create
and draw a rectangular grob.

`$grob_type` can be one of following,

- circle
- lines
- points
- polygon
- polyline
- rect
- segments
- text
- null
- zero

# ACKNOWLEDGEMENT

Thanks to Paul Murrell and his great R "grid" library, from which this Perl
library is ported.

# SEE ALSO

The R grid package [https://stat.ethz.ch/R-manual/R-devel/library/grid/html/grid-package.html](https://stat.ethz.ch/R-manual/R-devel/library/grid/html/grid-package.html)

[Graphics::Grid::Functions](https://metacpan.org/pod/Graphics::Grid::Functions)

Examples in the `examples` directory of the package release.

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
