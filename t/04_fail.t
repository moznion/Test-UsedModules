#!perl

use strict;
use warnings;
use utf8;
use FindBin;
push @INC, "$FindBin::Bin/resource/lib";
use Test::UsedModules;

use Test::More;
use Test::Builder::Tester;

foreach my $lib (map{"t/resource/lib/Test/UsedModules/Fail$_.pm"} 1..4) {
    if ($lib =~ /Fail\d*.pm/) {
        require "Test/UsedModules/$&";
    }
    test_out "not ok 1 - $lib";
    used_modules_ok($lib);
    test_test (name => "testing used_modules_ok($lib)", skip_err => 1);
}

done_testing;
