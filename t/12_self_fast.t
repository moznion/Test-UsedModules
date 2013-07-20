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

all_used_modules_ok();

done_testing;
