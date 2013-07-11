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

# Import as QuoteLike
use File::Spec::Functions qw/catdir/;
catdir('foo');

# Import as single quote
use File::Copy 'copy';
copy('foo', 'bar');

# Import as double quote
use File::Path "make_path";
make_path('foo', 'bar');

# Use as variable
use FindBin;
my $fb = $FindBin::Bin;

# Use as quote
use B;
my $hash = +{
    version => "$B::VERSION",
};

# Require
require File::Spec;
File::Spec->catfile('bar');

# XXX Exceptional!
# Exporter should be ignored.
use Exporter;

1;
