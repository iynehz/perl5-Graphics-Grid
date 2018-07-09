package Graphics::Grid::Util;

# ABSTRACT: Utility functions used internally in Graphics::Grid

use Graphics::Grid::Setup;

# VERSION

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(
  dots_to_cm cm_to_dots
  dots_to_inches inches_to_dots
  points_to_cm cm_to_points
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

fun dots_to_inches( $x, $dpi ) { $x / $dpi; }
fun inches_to_dots( $x, $dpi ) { $x * $dpi; }

fun dots_to_cm( $x, $dpi ) { $x / $dpi * 2.54; }
fun cm_to_dots( $x, $dpi ) { $x / 2.54 * $dpi; }

fun points_to_cm($x) { $x / 72.27 * 2.54; }
fun cm_to_points($x) { $x / 2.54 * 72.27; }

1;

__END__

=head1 SYNOPSIS

    use Graphics::Grid::Util qw(:all);

    # convert between dots and inches
    $inches = dots_to_inches($x, $dpi);
    $dots = inches_to_dots($x, $dpi);

    # convert between dots and centimeters
    $cm = dots_to_cm($x, $dpi);
    $dots = cm_to_dots($x, $dpi);

    # convert between points and centimeters   
    $cm = points_to_cm($x);
    $pt = cm_to_points($x);

=head1 SEE ALSO

L<Graphics::Grid>
