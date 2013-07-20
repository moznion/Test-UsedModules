#!perl

use strict;
use warnings;

# Test::UsedModules::Fast uses Compiler::Lexer.
# It is not up to user to install Compiler::Lexer.
BEGIN {
    use Test::More;
    eval 'use Compiler::Lexer';
    plan skip_all => "Compiler::Lexer required for testing Test::UsedModules::Fast" if $@ || $Compiler::Lexer::VERSION  < 0.13;
}

use Test::UsedModules::Fast;

my @expected = qw/all_used_modules_ok used_modules_ok/;
is_deeply \@Test::UsedModules::Fast::EXPORT, \@expected, 'export ok';

done_testing;
