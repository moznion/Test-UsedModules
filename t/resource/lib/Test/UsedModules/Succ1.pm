package Test::UsedModules::Succ1;
use strict;
use warnings;
use utf8;

# Use forth imported function
use Cwd;
my $cwd = getcwd();

# Use by not omit
use File::Basename ();
File::Basename::dirname('foo');

# Use by imported function by specifying
use File::Spec::Functions qw/catdir/;
catdir('foo');

# Use as variable
use FindBin;
my $fb = $FindBin::Bin;

# Use as quote
use Encode;
my $hash = +{
    version => "$Encode::VERSION",
};

# Require
require File::Spec;
File::Spec->catfile('bar');

# XXX Exceptional!
# Exporter should be ignored.
use Exporter;

1;
