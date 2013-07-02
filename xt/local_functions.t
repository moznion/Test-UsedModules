#!perl

use strict;
use warnings;
use Test::More;

eval {
    require Test::LocalFunctions;
};
plan skip_all => "Test::LocalFunctions required for testing variables" if $@;

all_local_functions_ok();
