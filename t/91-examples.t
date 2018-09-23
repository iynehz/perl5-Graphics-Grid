#!perl

use strict;
use warnings;

use Capture::Tiny qw(:all);
use Test2::V0;

my ($out, $err, $exit) = capture {
    system($^X, 'examples/run_all_examples.pl');
};
my $good = ok($exit == 0, 'run_all_examples.pl existed 0');

unless($good) { diag($err); }

done_testing;
