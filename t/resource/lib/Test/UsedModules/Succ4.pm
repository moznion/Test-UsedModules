package Test::UsedModules::Succ4;
use strict;
use warnings;
use utf8;

# Import as single quote
use File::Spec::Functions 'catdir';
catdir('foo');
1;
