#!perl

use strict;
use warnings;
use Test::More;

eval "use Test::Vars";
plan skip_all => "Test::Vars required for testing variables" if $@;

all_vars_ok();
