#!perl

use strict;
use warnings;
use utf8;
use FindBin;
push @INC, "$FindBin::Bin/resource/lib";

# Test::UsedModules::Fast uses Compiler::Lexer.
# It is not up to user to install Compiler::Lexer.
BEGIN {
    use Test::More;
    eval 'use Compiler::Lexer';
    plan skip_all => "Compiler::Lexer required for testing Test::UsedModules::Fast" if $@ || $Compiler::Lexer::VERSION  < 0.13;
}

use Test::UsedModules::Fast;

my @test_modules = glob "t/resource/lib/Test/UsedModules/Succ/*";
foreach my $lib (@test_modules) {
    if ($lib =~ /Succ\d*.pm/) {
        require "Test/UsedModules/$&";
    }
    used_modules_ok($lib);
}

done_testing;
