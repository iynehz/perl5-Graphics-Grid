package Graphics::Grid::Types;

# ABSTRACT: Custom types and coercions used by Graphics::Grid

use 5.014;
use warnings;

# VERSION

use Type::Library -base, -declare => qw(
  ValueWithUnit Unit GPar
  PointSymbol
  LineType LineEnd LineJoin
  FontFace
  Color
  Justification Clip
);

use Type::Utils -all;
use Types::Standard -types;

class_type ValueWithUnit, { class => 'Graphics::Grid::Unit' };
coerce ValueWithUnit,
  from Value,    via { 'Graphics::Grid::Unit'->new($_) },
  from ArrayRef, via { 'Graphics::Grid::Unit'->new($_) };

class_type GPar, { class => 'Graphics::Grid::GPar' };
coerce GPar, from HashRef, via { 'Graphics::Grid::GPar'->new($_) };

class_type Color, { class => 'Graphics::Color::RGB' };
coerce Color, from Str, via {
    if ( $_ =~ /^\#[[:xdigit:]]+$/ ) {
        'Graphics::Color::RGB'->from_hex_string($_);
    }
    else {
        'Graphics::Color::RGB'->from_color_library($_);
    }
};

declare Justification, as ArrayRef [Num], where { @$_ == 2 };
coerce Justification, from Str, via {
    state $mapping;
    unless ($mapping) {
        $mapping = {
            left   => [ 0,   0.5 ],
            top    => [ 0.5, 1 ],
            right  => [ 1,   0.5 ],
            bottom => [ 0.5, 0 ],
            center => [ 0.5, 0.5 ],
            centre => [ 0.5, 0.5 ],
        };
        $mapping->{bottom_left}  = $mapping->{left_bottom}  = [ 0, 0 ];
        $mapping->{top_left}     = $mapping->{left_top}     = [ 0, 1 ];
        $mapping->{bottom_right} = $mapping->{right_bottom} = [ 1, 0 ];
        $mapping->{top_right}    = $mapping->{right_top}    = [ 1, 1 ];
    }

    unless ( exists $mapping->{$_} ) {
        die "invalid justification";
    }
    return $mapping->{$_};
};

# For unit with multiple names, like "inches" and "in", we directly support
#  only one of its names, and handle other names via coercion.
declare Unit, as Enum [qw(npc cm inches mm points picas char)];
coerce Unit, from Str, via {
    state $mapping;
    unless ($mapping) {
        $mapping = {
            "in"         => "inches",
            "pt"         => "points",
            "pc"         => "picas",
            "centimetre" => "cm",
            "centimeter" => "cm",
            "millimiter" => "mm",
            "millimeter" => "mm",
        };
    }
    return ( $mapping->{$_} // $_ );
};

declare PointSymbol, as Int | Str;

declare LineType, as Enum [qw(blank solid dashed dotted dotdash longdash twodash)];
declare LineEnd, as Enum [qw(round butt square)];
declare LineJoin, as Enum [qw(round mitre bevel)];

declare FontFace, as Enum [qw(plain bold italic oblique bold_italic)];
coerce FontFace, from Str, via { sub { $_ =~ s/\./_/gr; } };

declare Clip, as Enum [qw(on off inherit)];

declare_coercion "ArrayRefFromAny", to_type ArrayRef, from Any, via { [$_] };
declare_coercion "ArrayRefFromValue", to_type ArrayRef, from Value,
  via { [$_] };

1;

__END__

=head1 SEE ALSO

L<Graphics::Grid>
