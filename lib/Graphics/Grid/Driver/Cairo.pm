package Graphics::Grid::Driver::Cairo;

# ABSTRACT: Cairo backend for Graphics::Grid

use Graphics::Grid::Class;

# VERSION

use Cairo;
use List::AllUtils qw(min max);
use Math::Trig qw(:pi :radial deg2rad);
use Path::Tiny;
use Types::Standard qw(Enum Str InstanceOf Num);

use Graphics::Grid::Util qw(dots_to_cm cm_to_dots points_to_cm);

my $AntialiasMode = Enum [qw(default none gray subpixel)];
my $Format =
  ( Enum [qw(pdf ps png svg)] )->plus_coercions( Str, sub { lc($_) } );

my $matrix_points_to_cm =
  Cairo::Matrix->init_scale( points_to_cm(1), -points_to_cm(1) );

=attr antialias_mode

The antialias mode of this driver.
Options are C<"default">, C<"none">, C<"gray"> and C<"subpixel">.

=cut

has 'antialias_mode' => ( is => 'rw', isa => $AntialiasMode );

=attr cairo

This driver's Cairo::Context object.

=cut

has 'cairo' => (
    is      => 'rw',
    isa     => 'Cairo::Context',
    clearer => 'clear_cairo',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $ctx  = Cairo::Context->create( $self->surface );

        if ( defined( $self->antialias_mode ) ) {
            $ctx->set_antialias( $self->antialias_mode );
        }

        return $ctx;
    }
);

=attr format

The format for this driver.

Allowed values are C<"png">, C<"svg">, C<"pdf">, C<"ps">. Default is C<"png">.

=cut

has format => ( is => 'ro', isa => $Format, default => 'png' );

=attr surface

The surface on which this driver is operating.

=cut

has 'surface' => (
    is      => 'rw',
    clearer => 'clear_surface',
    lazy    => 1,
    default => sub {

        # Lazily create our surface based on the format they are required
        # to've chosen when creating this object
        my $self = shift;

        my $surface;

        my $width  = $self->width;
        my $height = $self->height;

        if ( $self->format eq 'png' ) {
            $surface = Cairo::ImageSurface->create( 'argb32', $width, $height );
        }
        elsif ( $self->format eq 'pdf' ) {
            croak('Your Cairo does not have PDF support!')
              unless Cairo::HAS_PDF_SURFACE;
            $surface = Cairo::PdfSurface->create_for_stream(
                sub { $self->{DATA} .= $_[1] }, $self, $width, $height

                  # $self->can('append_surface_data'), $self, $width, $height
            );
        }
        elsif ( $self->format eq 'ps' ) {
            croak('Your Cairo does not have PostScript support!')
              unless Cairo::HAS_PS_SURFACE;
            $surface = Cairo::PsSurface->create_for_stream(
                sub { $self->{DATA} .= $_[1] }, $self, $width, $height

                  # $self->can('append_surface_data'), $self, $width, $height
            );
        }
        elsif ( $self->format eq 'svg' ) {
            croak('Your Cairo does not have SVG support!')
              unless Cairo::HAS_SVG_SURFACE;
            $surface = Cairo::SvgSurface->create_for_stream(
                sub { $self->{DATA} .= $_[1] }, $self, $width, $height

                  # $self->can('append_surface_data'), $self, $width, $height
            );
        }
        else {
            croak( "Unknown format '" . $self->format . "'" );
        }

        return $surface;
    }
);

has _current_viewport_width_cm  => ( is => 'rw' );
has _current_viewport_height_cm => ( is => 'rw' );

with qw(Graphics::Grid::Driver);

method _set_vptree( $vptree, $old_vptree = undef ) {
    my $ctx = $self->cairo;

    my $path = $self->current_vptree->path_from_root;

    # reset to basic setup
    $self->_reset_transform();

    # bypass root vp
    shift @$path;

    my $parent_width  = dots_to_cm( $self->width,  $self->dpi );
    my $parent_height = dots_to_cm( $self->height, $self->dpi );

    for my $vp (@$path) {
        my $x_vec      = $vp->x->as_cm($parent_width);
        my $y_vec      = $vp->y->as_cm($parent_height);
        my $width_vec  = $vp->width->as_cm($parent_width);
        my $height_vec = $vp->height->as_cm($parent_height);

        my ( $x, $y, $width, $height ) =
          map { $_->value_at(0) } ( $x_vec, $y_vec, $width_vec, $height_vec );

        $ctx->translate( $x, $y );

        if ( $vp->angle != 0 ) {
            $ctx->rotate( deg2rad( $vp->angle ) );
        }

        $ctx->translate( -$vp->hjust * $width, -$vp->vjust * $height );

        $parent_width  = $width;
        $parent_height = $height;
    }

    $self->_current_viewport_width_cm($parent_width);
    $self->_current_viewport_height_cm($parent_height);
}

method _reset_transform() {
    my $ctx = $self->cairo;

    # reset transfom
    my $identity_matrix = Cairo::Matrix->init_identity;
    $ctx->set_matrix($identity_matrix);

    #$ctx->set_font_matrix($identity_matrix);

    # set basic transform below

    # Cairo's Y direction is inverse from that of the grid library
    $ctx->translate( 0, $self->height );

    # We defaultly use cm as unit
    $self->_set_scale_cm();

}

method _set_scale_cm() {
    my $ctx = $self->cairo;
    $ctx->scale( $self->dpi / 2.54, -$self->dpi / 2.54 );
}
method _unset_scale_cm() {
    my $ctx = $self->cairo;
    $ctx->scale( 2.54 / $self->dpi, -2.54 / $self->dpi );
}

=method data()

Get the data in a scalar for this driver.

=cut

method data() {
    my $ctx = $self->cairo;

    if ( $self->format eq 'png' ) {
        my $buff;
        $self->surface->write_to_png_stream(
            sub {
                my ( $closure, $data ) = @_;
                $buff .= $data;
            }
        );
        return $buff;
    }

    $ctx->show_page;

    $ctx = undef;
    $self->clear_cairo;
    $self->clear_surface;

    return $self->{DATA};
}

method _reset_dash() {
    $self->cairo->set_dash( 0, [] );
}

method draw_circle($circle_grob) {
    my $ctx = $self->cairo;

    my $parent_width  = $self->_current_viewport_width_cm;
    my $parent_height = $self->_current_viewport_height_cm;

    my $x_vec = $circle_grob->x->as_cm($parent_width);
    my $y_vec = $circle_grob->y->as_cm($parent_height);
    my $r_vec = $circle_grob->r->as_cm( min( $parent_width, $parent_height ) );

    my $gp_vec = $self->_get_effective_gp($circle_grob);

    for my $idx ( 0 .. $circle_grob->elems - 1 ) {

        my ( $x, $y, $r ) =
          map { $_->value_at($idx); } ( $x_vec, $y_vec, $r_vec );
        my $gp = $gp_vec->at($idx);

        $self->_draw_shape(
            $gp,
            sub {
                my $c = shift;
                $c->new_path;
                $c->arc( $x, $y, $r, 0, pi2 );
            },
            true,
        );
    }
}

method draw_rect($rect_grob) {
    my $ctx = $self->cairo;

    my $parent_width  = $self->_current_viewport_width_cm;
    my $parent_height = $self->_current_viewport_height_cm;

    my $x_vec      = $rect_grob->x->as_cm($parent_width);
    my $y_vec      = $rect_grob->y->as_cm($parent_height);
    my $width_vec  = $rect_grob->width->as_cm($parent_width);
    my $height_vec = $rect_grob->height->as_cm($parent_height);

    my $gp_vec = $self->_get_effective_gp($rect_grob);

    for my $idx ( 0 .. $rect_grob->elems - 1 ) {
        my ( $x, $y, $width, $height ) = map { $_->value_at($idx) }
          ( $x_vec, $y_vec, $width_vec, $height_vec );
        my $gp = $gp_vec->at($idx);

        my ( $left, $bottom ) =
          $rect_grob->calc_left_bottom( $x, $y, $width, $height );

        $self->_draw_shape(
            $gp,
            sub {
                my $c = shift;
                $c->new_path;
                $c->rectangle( $left, $bottom, $width, $height );
            },
            true
        );
    }
}

method draw_polyline($polyline_grob) {
    $self->_draw_polyline(
        $polyline_grob,
        fun( $c, $points )
        {
            $c->new_path;
            my $start_point = shift @$points;
            $c->move_to(@$start_point);
            for my $point (@$points) {
                $c->line_to(@$point);
            }
        },
        false
    );
}

method draw_polygon($polygon_grob) {
    $self->_draw_polyline(
        $polygon_grob,
        fun( $c, $points )
        {
            $c->new_path;
            my $start_point = shift @$points;
            $c->move_to(@$start_point);
            for my $point (@$points) {
                $c->line_to(@$point);
            }
            $c->close_path;
        },
        true
    );
}

method _draw_polyline( $polyline_grob, $path_func, $is_fill = false ) {
    my $ctx = $self->cairo;

    my $parent_width  = $self->_current_viewport_width_cm;
    my $parent_height = $self->_current_viewport_height_cm;

    my $gp_vec = $self->_get_effective_gp($polyline_grob);

    for my $idx ( 0 .. $polyline_grob->elems - 1 ) {
        my $points = $polyline_grob->get_points($idx);

        # do not draw if there are less than 2 points
        next if ( @$points < 2 );

        my @points_cm = map {
            my $x = $_->[0]->as_cm($parent_width)->value_at(0);
            my $y = $_->[1]->as_cm($parent_width)->value_at(0);
            [ $x, $y ];
        } @$points;

        my $gp = $gp_vec->at($idx);
        $self->_draw_shape( $gp, fun($c) { $path_func->( $c, \@points_cm ); },
            $is_fill );
    }
}

method _set_dash_by_line_type($line_type) {
    my $ctx = $self->cairo;

    #my $dash = $top->dash_pattern;
    #if(defined($dash) && scalar(@{ $dash })) {
    #    $context->set_dash(0, @{ $dash });
    #}
}

method _draw_shape( $gp, $path_func, $is_fill = false ) {
    my $ctx = $self->cairo;

    # draw path
    $path_func->($ctx);

    # fill
    if ($is_fill) {
        $self->_set_fill($gp);
        $ctx->fill_preserve;
    }

    my $line_type = $gp->lty->[0];
    my $line_width = max( $gp->lwd->[0] * $gp->lex->[0], 1 );
    if ( $line_type ne 'blank' and $line_width ) {

        # grid's lineend/linejoin enums are same as Cairo's line_cap/line_join
        $ctx->set_line_cap( $gp->lineend->[0] );
        $ctx->set_line_join( $gp->linejoin->[0] );

        $ctx->set_miter_limit( $gp->linemitre->[0] );

        $self->_set_color($gp);
        $self->_set_dash_by_line_type($line_type);

        # $line_width is in absolute dots
        my $matrix = $ctx->get_matrix();
        $self->_unset_scale_cm();
        $ctx->set_line_width($line_width);
        $ctx->stroke;
        $ctx->set_matrix($matrix);

        # reset dash
        $self->_reset_dash();

        return 1;
    }
    return 0;
}

method _set_color($gp) {
    my $ctx   = $self->cairo;
    my $color = $gp->col->[0];
    $color->alpha( $gp->alpha->[0] ) if $gp->has_alpha;
    $ctx->set_source_rgba( $color->as_array_with_alpha );
}

method _set_fill($gp) {
    my $ctx   = $self->cairo;
    my $color = $gp->fill->[0];
    $color->alpha( $gp->alpha->[0] ) if defined $gp->has_alpha;
    $ctx->set_source_rgba( $color->as_array_with_alpha );
}

method _select_font_face($gp) {
    my $ctx        = $self->cairo;
    my $fontfamily = $gp->fontfamily->[0];
    my $fontface   = $gp->fontface->[0];

    state $fontface_to_params = {
        plain       => [ 'normal',  'normal' ],
        bold        => [ 'normal',  'bold' ],
        italic      => [ 'italic',  'normal' ],
        oblique     => [ 'oblique', 'normal' ],
        bold_italic => [ 'italic',  'bold' ],
    };

    $ctx->select_font_face( $fontfamily,
        @{ $fontface_to_params->{$fontface} } );
}

method draw_text($text_grob) {
    my $ctx = $self->cairo;

    my $parent_width  = $self->_current_viewport_width_cm;
    my $parent_height = $self->_current_viewport_height_cm;

    my $x_vec = $text_grob->x->as_cm($parent_width);
    my $y_vec = $text_grob->y->as_cm($parent_height);

    my $gp_vec = $self->_get_effective_gp($text_grob);

    for my $idx ( 0 .. $text_grob->elems - 1 ) {
        my $text = $text_grob->label->[$idx];
        next unless ( length($text) );

        my $x = $x_vec->value_at($idx);
        my $y = $y_vec->value_at($idx);

        my $gp = $gp_vec->at($idx);

        # Cairo does not support multiline text, so $gp->lineheight is not used

        my $font_size =
          max( $gp->fontsize->[0] * $gp->cex->[0], 1 );

        $ctx->set_font_size($font_size);
        my $font_matrix = $ctx->get_font_matrix->multiply($matrix_points_to_cm);
        $ctx->set_font_matrix($font_matrix);

        $self->_select_font_face($gp);
        my $exts = $ctx->text_extents($text);

        my $width  = $exts->{width};
        my $height = $exts->{height};

        my ( $left, $bottom ) =
          $text_grob->calc_left_bottom( $x, $y, $width, $height );

        $self->_set_color($gp);

        #$ctx->save;

        #my $angle_rad = deg2rad($text_grob->rot->[$idx]);
        #if ($angle_rad) {
        #    $ctx->translate($x, $y);
        #    $ctx->rotate($angle_rad);
        #    $ctx->translate(-$x, -$y);
        #}
        $ctx->move_to( $left, $bottom );
        $ctx->show_text($text);

        #ctx->restore;
    }
}

=method write($file)

Write this driver's data to the specified file.

=cut

method write($file) {
    path($file)->spew_raw( $self->data );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 DESCRIPTION

This module draws Graphics::Grid objects using Cairo.
It is a subclass of L<Graphics::Grid::Driver>.

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::Driver>

