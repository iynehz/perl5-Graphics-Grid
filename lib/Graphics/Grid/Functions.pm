package Graphics::Grid::Functions;

# ABSTRACT: Function interface for Graphics::Grid

use Graphics::Grid::Setup;

# VERSION

use Module::Load;
use Types::Standard qw(ArrayRef);

use Graphics::Grid::GPar;
use Graphics::Grid::GTree;
use Graphics::Grid::Grill;
use Graphics::Grid::Layout;
use Graphics::Grid::Unit;
use Graphics::Grid::UnitList;
use Graphics::Grid::Viewport;
use Graphics::Grid::ViewportTree;
use Graphics::Grid;

my @grob_types = Graphics::Grid->_grob_types();

use parent qw(Exporter::Tiny);

our @EXPORT_OK = (
    qw(
      unit unit_c gpar viewport viewport_tree grid_layout
      grid_write grid_draw grid_driver
      push_viewport pop_viewport up_viewport down_viewport seek_viewport
      gtree grill grid_grill
      grob_name
      grob_width grob_height
      ), ( map { ( "grid_${_}", "${_}_grob" ) } @grob_types )
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

my $grid = Graphics::Grid->singleton;    # global object

=func grid_driver(:$driver='Cairo', %rest)

Set the device driver. If you don't run this function, the default driver
will be effective.

If C<$driver> consumes Graphics::Grid::Driver, C<$driver> is assigned to
the global Graphics::Grid object, and C<%rest> is ignored.

    grid_driver(driver => Graphics::Grid::Driver::Cairo->new(...));

If C<$driver> is a string, a Graphics::Grid::Driver::$driver object is
created with C<%rest> as construction parameters, and is assigned to the
global Graphics::Grid object.

    grid_driver(driver => 'Cairo', width => 800, height => 600);

You may run it at the the beginning of you code. At present changing driver
settings at the middle is not guarenteed to work.

This function returns current width and height.

    my $driver = grid_device();

=cut

fun grid_driver ( :$driver = 'Cairo', %rest ) {
    if ( $driver->DOES('Graphics::Grid::Driver') ) {
        $grid->driver($driver);
    }
    else {
        my $cls = "Graphics::Grid::Driver::$driver";
        load $cls;
        $grid->driver( $cls->new(%rest, grid => $grid) );
    }
    return $grid->driver;
}

=func unit(%params)

It's same as C<Graphics::Grid::Unit-E<gt>new>.

=func unit_c(@unit_objs)

It's same as C<Graphics::Grid::UnitList-E<gt>new>.

=cut

sub unit {
    return Graphics::Grid::Unit->new(@_);
}

sub unit_c {
    return Graphics::Grid::UnitList->new(@_);
}

=func gpar(%params)

It's same as C<Graphics::Grid::GPar-E<gt>new>.

=cut

sub gpar {
    return Graphics::Grid::GPar->new(@_);
}

=func viewport(%params)

It's same as C<Graphics::Grid::Viewport-E<gt>new>.

=func viewport_tree($parent, $children)

It's same as C<Graphics::Grid::ViewportTree-E<gt>new>.

=cut

sub viewport {
    return Graphics::Grid::Viewport->new(@_);
}

sub viewport_tree {
    return Graphics::Grid::ViewportTree->new(@_);
}

=func push_viewport($viewport)

It's same as Graphics::Grid's C<push_viewport> method.

=func pop_viewport($n=1)

It's same as Graphics::Grid's C<pop_viewport> method.

=func up_viewport($n=1)

It's same as Graphics::Grid's C<up_viewport> method.

=func down_viewport($from_tree_node, $name)

It's same as Graphics::Grid's C<down_viewport> method.

=func seek_viewport($name)

It's same as Graphics::Grid's C<seek_viewport> method.

=cut

for my $method (
    qw(
    push_viewport pop_viewport up_viewport down_viewport seek_viewport
    )
  )
{
    no strict 'refs';    ## no critic
    *{$method} = sub { $grid->$method(@_); }
}

=func grid_layout(%prams)

It's same as C<Graphics::Grid::Layout-E<gt>new>.

=cut

sub grid_layout {
    return Graphics::Grid::Layout->new(@_);
}

=func grid_draw($grob)

It's same as Graphics::Grid's C<draw> method.

=func grid_write($filename)

It's same as Graphics::Grid's C<write> method.

=cut

sub grid_draw {
    return $grid->draw(@_);
}

sub grid_write {
    return $grid->write(@_);
}

=head2 ${grob_type}_grob(%params)

This creates a grob object.

C<$grob_type> can be one of following,

=include grob_types@Graphics::Grid

=head2 grid_${grob_type}(%params)

This creates a grob, and draws it. This is same as Graphics::Grid's
${grob_type}(...) method.

See above for possible C<$grob_type>.

=cut

fun grob_name ($grob, @rest) {
    return $grob->gen_grob_name(@rest);
}

for my $grob_type (@grob_types) {
    my $class = 'Graphics::Grid::Grob::' . ucfirst($grob_type);
    load $class;

    my $grob_func = sub {
        my $grob = $class->new(@_);
    };

    no strict 'refs';    ## no critic
    *{ $grob_type . "_grob" } = $grob_func;
    *{ "grid_" . $grob_type } = sub { $grid->$grob_type(@_); };
}

=func gtree(%params)

It's same as C<Graphics::Grid::GTree-E<gt>new>.

=cut

sub gtree {
    return Graphics::Grid::GTree->new(@_);
}

=func grill(%params)

This creates a grill object.

=func grid_grill(%params)

This creates a grill object and draws it.

=cut

sub grill {
    return Graphics::Grid::Grill->new(@_);
}

sub grid_grill {
    my $grill = Graphics::Grid::Grill->new(@_);
    return $grid->draw($grill);
}

=func grob_width($grob)

=func grob_height($grob)

=cut

fun grob_width($grob) { $grob->grob_width($grid); }
fun grob_height($grob) { $grob->grob_height($grid); }

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Functions qw(:all);

    grid_driver( width => 900, height => 300, format => 'svg' );
    grid_rect();    # draw white background

    for my $setting (
        { color => 'red',   x => 1 / 6 },
        { color => 'green', x => 0.5 },
        { color => 'blue',  x => 5 / 6 }
      )
    {
        push_viewport(
            viewport( x => $setting->{x}, y => 0.5, width => 0.2, height => 0.6 ) );
        grid_rect( gp => { fill => $setting->{color}, lty => 'blank' } );
        grid_text( label => $setting->{color}, y => -0.1 );

        pop_viewport();
    }

    grid_write("foo.svg");

=head1 DESCRIPTION

This is the function interface for L<Graphics::Grid>. In this package
it has a global Graphics::Grid object, on which the functions are
operated.

=head1 SEE ALSO

L<Graphics::Grid>

Examples in the C<examples> directory of the package release.

