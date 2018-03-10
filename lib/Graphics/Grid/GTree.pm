package Graphics::Grid::GTree;

# ABSTRACT: gtree

use Graphics::Grid::Class;

# VERSION

extends qw(Forest::Tree);

use Types::Standard qw(ArrayRef InstanceOf);
use namespace::autoclean;

has '+children' => ( isa => ArrayRef [ InstanceOf ['Graphics::Grid::GTree'] ] );

with qw(Graphics::Grid::Grob);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my %params = @_;
    my $children = ( delete $params{children} ) // [];
    $children =
      [ map { $_->$_isa(__PACKAGE__) ? $_ : __PACKAGE__->new( node => $_ ); }
          @$children ];

    $class->$orig( %params, children => $children );
};

method _build_elems() {
    return $self->child_count;
}

method draw($driver) {
    for my $child ( @{ $self->children } ) {
        if ( $child->node->$_can('draw') ) {
            $child->node->draw($driver);
        }
        else {
            $child->draw($driver);
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    use Graphics::Grid::GTree;
    use Graphics::Grid::GPar;
    my $gtree = Graphics::Grid::GTree->new(
        children => [
            Graphics::Grid::Grob::Rect->new(...),
            Graphics::Grid::Grob::Points->new(...),
        ]
        gp => Graphics::Grid::GPar->new(...),
    );

    # or use the function interface
    use Graphics::Grid::Functions qw(:all);
    my $gtree = gtree(%params);

=head1 DESCRIPTION

A "gtree" can have other grobs as children. When a gtree is dawn, it draws
all of its children.

It is a subclass of L<Forest::Tree>.

=head1 SEE ALSO

L<Graphics::Grid::Grob>

L<Forest::Tree>


