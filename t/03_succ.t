#!perl

use strict;
use warnings;
use utf8;
use FindBin;
push @INC, "$FindBin::Bin/resource/lib";
use Test::UsedModules;

use Test::More;

foreach my $lib (map{"t/resource/lib/Test/UsedModules/Succ$_.pm"} 1..1) {
    if ($lib =~ /Succ\d*.pm/) {
        require "Test/UsedModules/$&";
    }
    used_modules_ok($lib);
}

done_testing;
