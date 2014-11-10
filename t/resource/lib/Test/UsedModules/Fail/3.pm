package Test::UsedModules::Fail::3;
use strict;
use warnings;
use utf8;

# meta: whitelist: File::Spec::Functions
use File::Spec::Functions qw/catfile/;

1;
