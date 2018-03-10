package Graphics::Grid::Functions;

# ABSTRACT: Function interface for Graphics::Grid

use Graphics::Grid::Setup;

# VERSION

use Module::Load;

use Graphics::Grid;
use Graphics::Grid::GPar;
use Graphics::Grid::Unit;
use Graphics::Grid::Viewport;
use Graphics::Grid::GTree;

my @grob_types = Graphics::Grid->_grob_types();

use Exporter 'import';
our @EXPORT_OK = (
    qw(
      unit gpar viewport
      grid_write grid_draw
      push_viewport pop_viewport up_viewport down_viewport seek_viewport
      gtree
      ), ( map { ( "grid_${_}", "${_}_grob" ) } @grob_types )
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

my $grid = Graphics::Grid->singleton;

sub unit {
    return Graphics::Grid::Unit->new(@_);
}

sub gpar {
    return Graphics::Grid::GPar->new(@_);
}

sub viewport {
    return Graphics::Grid::Viewport->new(@_);
}

sub grid_draw {
    $grid->draw(@_);
}

sub grid_write {
    $grid->driver->write(@_);
}

sub gtree {
    return Graphics::Grid::GTree->new(@_);
}

for my $grob_type (@grob_types) {
    my $class = 'Graphics::Grid::Grob::' . ucfirst($grob_type);
    load $class;

    my $grob_func = sub {
        my $grob = $class->new(@_);
    };

    no strict 'refs';    ## no critic
    *{ $grob_type . "_grob" } = $grob_func;
    *{ "grid_" . $grob_type } = sub {
        $grid->$grob_type(@_);
    };
}

for my $method (
    qw(
    push_viewport pop_viewport up_viewport down_viewport seek_viewport
    )
  )
{
    no strict 'refs';    ## no critic
    *{$method} = sub { $grid->$method(@_); }
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Functions qw(:all);


=head1 DESCRIPTION

This is the function interface for L<Graphics::Grid>.

=head1 FUNCTIONS

=head2 unit(%params)

It's equivalent to C<Graphics::Grid::Unit-E<gt>new>.

=head2 viewport(%params)

It's equivalent to C<Graphics::Grid::Viewport-E<gt>new>.

=head2 gpar(%params)

It's equivalent to C<Graphics::Grid::GPar-E<gt>new>.

=head2 push_viewport($viewport)

It's equivalent to Graphics::Grid's C<push_viewport> method.

=head2 pop_viewport($n=1)

It's equivalent to Graphics::Grid's C<pop_viewport> method.

=head2 up_viewport($n=1)

It's equivalent to Graphics::Grid's C<up_viewport> method.

=head2 down_viewport($from_tree_node, $name)

It's equivalent to Graphics::Grid's C<down_viewport> method.

=head2 seek_viewport($name)

It's equivalent to Graphics::Grid's C<seek_viewport> method.

=head2 ${grob_type}_grob(%params)

This creates a grob object.

C<$grob_type> can be one of following,

=include grob_types@Graphics::Grid

=head2 grid_${grob_type}(%params)

This creates a grob, and draws it. This is equivalent to Graphics::Grid's
${grob_type}(...) method.

See above for possible C<$grob_type>.

=head2 gtree(%params)

It's equivalent to C<Graphics::Grid::GTree-E<gt>new>.

=head2 grid_draw($grob)

It's equivalent to Graphics::Grid's C<draw> method.

=head2 grid_write($filename)

It's equivalent to Graphics::Grid's C<write> method.

=head1 SEE ALSO

L<Graphics::Grid>

Examples in the C<examples> directory of the package release.

