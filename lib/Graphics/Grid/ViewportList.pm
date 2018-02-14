package Graphics::Grid::ViewportList;

use strict;
use warnings;

use Function::Parameters qw(:std classmethod);

classmethod new(@vps) {
    return bless(\@vps, $class);
}

1;
