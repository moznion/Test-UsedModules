package Test::UsedModules::Succ12;
use strict;
use warnings;
use utf8;
use Module::Load;

# XXX it cannot detect...
my $module = 'File::Basename';
load $module;
1;
