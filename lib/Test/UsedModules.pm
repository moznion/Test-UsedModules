package Test::UsedModules;
use 5.008005;
use strict;
use warnings;
use utf8;
use parent qw/Test::Builder::Module/;
use ExtUtils::Manifest qw/maniread/;
use Test::UsedModules::PPIDocument;

our $VERSION = "0.01";
our @EXPORT  = qw/all_used_modules_ok used_modules_ok/;

sub all_used_modules_ok {
    my $builder   = __PACKAGE__->builder;
    my @lib_files = _list_modules_in_manifest($builder);

    $builder->plan( tests => scalar @lib_files );

    my $fail = 0;
    for my $file (@lib_files) {
        _used_modules_ok( $builder, $file ) or $fail++;
    }

    return $fail == 0;
}

sub used_modules_ok {
    my ($lib_file) = @_;
    return _used_modules_ok( __PACKAGE__->builder, $lib_file );
}

sub _used_modules_ok {
    my ( $builder, $file ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $pid = fork;
    if ( defined $pid ) {
        if ( $pid != 0 ) {
            # Parent process
            wait;
            return $builder->ok( $? == 0, $file );
        }
        # Child processes
        exit _check_used_modules( $builder, $file );
    }

    die "fail forking: $!";
}

sub _check_used_modules {
    my ( $builder, $file ) = @_;

    my $ppi_document                = Test::UsedModules::PPIDocument::generate($file);
    my $ppi_document_without_symbol = Test::UsedModules::PPIDocument::generate($file, 'Symbol');

    my @used_modules = Test::UsedModules::PPIDocument::fetch_modules_in_module($file);

    my $fail = 0;
    CHECK: for my $used_module (@used_modules) {
        next if $ppi_document =~ /$used_module->{name}/;

        my @imported_subs = _fetch_imported_subs($used_module);
        for my $sub (@imported_subs) {
            next CHECK if $ppi_document_without_symbol =~ /$sub/;
        }

        $builder->diag( "Test::UsedModules failed: '$used_module->{name}' is not used.");
        $fail++;
    }

    return $fail;
}

sub _fetch_imported_subs {
    my ($used_module) = @_;

    my $importer = sprintf "%s %s", $used_module->{type}, $used_module->{name};
    if ( my $extend = $used_module->{extend} ) {
        $extend =~ s/\( \.\.\. \)/()/;
        $importer = sprintf "%s %s", $importer, $extend;
    }

    my %imported_refs;
    no strict 'refs';
    %{'Test::UsedModules::Imported::Sandbox::'} = ();
    use strict;

    eval "package Test::UsedModules::Imported::Sandbox;" ## no critic
      . "$importer;"
      . "no strict 'refs';"
      . "%imported_refs = %{'Test::UsedModules::Imported::Sandbox::'};";

    delete $imported_refs{BEGIN};
    return keys %imported_refs;
}

sub _list_modules_in_manifest {
    my ($builder) = @_;

    my $manifest = $ExtUtils::Manifest::MANIFEST;
    if ( not -f $manifest ) {
        $builder->plan( skip_all => "$manifest doesn't exist" );
    }
    my @modules = grep { m!\Alib/.*\.pm\Z! } keys %{ maniread() };
    return @modules;
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::UsedModules - Detects needless modules which are being used in your module

=head1 SYNOPSIS

    use Test::UsedModules;

=head1 DESCRIPTION

Test::UsedModules is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

