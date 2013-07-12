package Test::UsedModules::Succ11;
use strict;
use warnings;
use utf8;
use Module::Load;

load File::Basename;
File::Basename::dirname('foo');
1;
