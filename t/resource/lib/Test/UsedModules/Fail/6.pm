package Test::UsedModules::Fail::6;
use strict;
use warnings;
use utf8;

use Module::Load;

# meta: whitelist: File::Basename
load File::Basename;

1;
