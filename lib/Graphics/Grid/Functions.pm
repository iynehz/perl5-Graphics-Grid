package Graphics::Grid::Functions;

# ABSTRACT: Function interface for Graphics::Grid

use Graphics::Grid::Setup;

# VERSION

use Module::Load;

use Graphics::Grid;
use Graphics::Grid::GPar;
use Graphics::Grid::Unit;
use Graphics::Grid::Viewport;

my @grob_types = qw(circle lines polygon polyline rect text zero);

use Exporter 'import';
our @EXPORT_OK = (
    qw(
      unit gpar viewport
      grid_write grid_draw
      push_viewport pop_viewport up_viewport down_viewport seek_viewport
      ), ( map { ("grid_${_}", "${_}_grob") } @grob_types )
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
    $grid->draw_grob(@_);
}

sub grid_write {
    $grid->driver->write(@_);
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

This is the function interface for Graphics::Grid.

=head1 SEE ALSO

L<Graphics::Grid>

