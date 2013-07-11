package Test::UsedModules::Succ7;
use strict;
use warnings;
use utf8;

# Call as quote
use B;
my $hash = +{
    version => "$B::VERSION",
};

1;
