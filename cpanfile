requires 'PPI::Document';
requires 'PPI::Dumper';
requires 'Test::Builder::Module';
requires 'parent';
requires 'perl', '5.008005';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'Test::Builder::Tester';
    requires 'Test::More', '0.98';
};

on develop => sub {
    requires 'Test::LocalFunctions';
    requires 'Test::Perl::Critic';
    requires 'Test::Vars';
};
