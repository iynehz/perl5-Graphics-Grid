package Graphics::Grid::ViewportTree;

# ABSTRACT: Viewport tree

use Graphics::Grid::Class;

# VERSION

extends qw(Forest::Tree);

use namespace::autoclean;

use Types::Standard qw(ArrayRef InstanceOf);

use Graphics::Grid::Viewport;

has '+children' => ( isa => ArrayRef [ InstanceOf ['Graphics::Grid::ViewportTree'] ] );

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

=method node() 

    my $viewport = $tree->node;

Get the viewport from the tree node. 

=method path_from_root()

    my $viewports = $tree->path_from_root();

Return an array of viewports, starting from the root node of the whole
tree, all the way down in the tree and to the calling node.

=cut

# return an arrayref of Viewport from root
method path_from_root() {
    my $tree = $self;
    my @path = ($tree->node);
    while ($tree->has_parent) {
        my $parent = $tree->parent;
        push @path, $parent->node;
        $tree = $parent;
    }
    @path = reverse(@path);
    return \@path;
}

=method stringify()

    my $tree_as_a_string = $tree->stringify();

Return the tree structure as a string.

=cut

method stringify () {
    if ( $self->is_leaf ) {
        return sprintf( "Viewport[%s]", $self->node->name );
    }
    else {
        return sprintf(
            "Viewport[%s]->(%s)",
            $self->node->name,
            join( ',',
                map { $_->stringify() } @{ $self->children } )
        );
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

This is a subclass of L<Forest::Tree>, storing viewports at tree nodes.

=head1 SEE ALSO

L<Graphics::Grid::Viewport>

L<Forest::Tree>


