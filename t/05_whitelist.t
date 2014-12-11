#!perl

use strict;
use warnings;
use utf8;
use FindBin;
push @INC, "$FindBin::Bin/resource/lib";
use Test::UsedModules;

use Test::More;
use Test::Builder::Tester;

my @test_modules = glob "t/resource/lib/Test/UsedModules/Fail/*";
foreach my $lib (@test_modules) {
    if ($lib =~ /Fail(\d*).pm/) {
        require "Test/UsedModules/$1";
    }

    # test that the code fails with the default whitelist
    test_out "not ok 1 - $lib";
    used_modules_ok($lib);
    test_test (name => "testing used_modules_ok($lib)", skip_err => 1);

    # test that the code passes with the whitelist that includes whatever's specified in the file
    my $whitelist = get_whitelist($lib);
    local $Test::UsedModules::MODULES_WHITELIST = [ @$Test::UsedModules::MODULES_WHITELIST, @$whitelist ];
    used_modules_ok($lib);
}

done_testing;

sub slurp {
    my ($filename) = @_;

    open my $fh, '<', $filename;
    return do { local $/; <$fh> };
}

sub get_whitelist {
    my ($filename) = @_;

    my $contents = slurp $filename;
    my @whitelist;
    if ( $contents =~ /^# meta: whitelist: (.*?)$/m ) {
        my $modules = $1;
        @whitelist = split /\s*,\s*/, $modules;
    }

    return \@whitelist;
}
