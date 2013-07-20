package Test::UsedModules::Fast;
use 5.008005;
use strict;
use warnings;
use utf8;
use parent qw/Test::Builder::Module/;
use ExtUtils::Manifest qw/maniread/;
use Compiler::Lexer;
use Test::UsedModules::Constants;

our @EXPORT  = qw/all_used_modules_ok used_modules_ok/;

sub all_used_modules_ok {
    my $builder   = __PACKAGE__->builder;
    my @lib_files = _list_up_modules_from_manifest($builder);

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

    my ($documents, $used_modules) = _lexer( $file );

    my $fail = 0;
    CHECK: for my $used_module (@{$used_modules}) {
        next if $used_module->{name} eq 'Exporter';
        next if $documents =~ /$used_module->{name}/;

        my @imported_subs = _fetch_imported_subs($used_module);
        for my $sub (@imported_subs) {
            next CHECK if $documents =~ /$sub/;
        }

        $builder->diag( "Test::UsedModules::Fast failed: '$used_module->{name}' is not used.");
        $fail++;
    }

    return $fail;
}

sub _fetch_imported_subs {
    my ($used_module) = @_;
    my $importer = "$used_module->{type} $used_module->{name}";

    if ( my $extend = $used_module->{extend} ) {
        $importer .= " $extend";
    }

    my %imported_refs;
    no strict 'refs';
    %{'Test::UsedModules::Sandbox::'} = ();
    use strict;

    eval <<EOC; ## no critic
package Test::UsedModules::Sandbox;
$importer;
no strict 'refs';
%imported_refs = %{'Test::UsedModules::Sandbox::'};
EOC

    delete $imported_refs{BEGIN};
    return keys %imported_refs;
}

sub _list_up_modules_from_manifest {
    my ($builder) = @_;

    my $manifest = $ExtUtils::Manifest::MANIFEST;
    if ( not -f $manifest ) {
        $builder->plan( skip_all => "$manifest doesn't exist" );
    }
    return grep { m!\Alib/.*\.pm\Z! } keys %{ maniread() };
}

sub _lexer {
    my $file = shift;

    open my $fh, '<', $file or die "Can not open the file: $!";
    my $code = do { local $/; <$fh> };
    close $fh;

    my $lexer = Compiler::Lexer->new($file);

    my %pragmas = map { $_ => 1 } PRAGMAS;
    my $top = 1;
    my $module_decl = 0;
    my $module_name = 0;
    my ($documents, $used_module, $used_modules);

    my $load_called = 0;
    for my $token ( @{$lexer->tokenize($code)} ) {
        if ($top) {
            if ($token->{name} =~ /^(UseDecl|RequireDecl)$/) {
                $module_decl = 1;
            }
            elsif ($token->{name} eq 'Key' && $token->{data} eq 'load') {
                $module_decl = 1;
            }
        }
        $top = 0;

        if ($module_decl) {
            if ($token->{name} eq 'UseDecl') {
                $used_module->{type} = 'use';
                $module_name = 1;
            } elsif ($token->{name} eq 'RequireDecl') {
                $used_module->{type} = 'require';
                $module_name = 1;
            } elsif ($token->{name} eq 'Key' && $token->{data} eq 'load') {
                $used_module->{type} = 'load';
                $module_name = 1;
                $load_called = 1;
            } elsif ($token->{name} =~ /(NamespaceResolver|Namespace|UsedName)/ && $module_name) {
                $used_module->{name} .= $token->{data};
            } elsif ($token->{name} eq 'SemiColon') {
                if (defined $used_module->{name}) {
                    if ($pragmas{$used_module->{name}}) {
                        $documents .= $used_module->{type} . $used_module->{name} . ($used_module->{extend} || '');
                    } else {
                        push @{$used_modules}, {
                            name => $used_module->{name},
                            type => $used_module->{type},
                            extend => $used_module->{extend} || undef,
                        };
                    }
                }
                undef $used_module;
                $module_decl = 0;
            } else {
                if ($token->{name} eq 'RawString') {
                    $used_module->{extend} .= "'$token->{data}'";
                } else {
                    $used_module->{extend} .= $token->{data};
                }
                $module_name = 0;
            }
        } else {
            $documents .= $token->{data};
        }
        $top = $token->{name} eq 'SemiColon' ? 1 : 0;
    }

    if ($load_called) {
        @$used_modules = grep { $_->{name} ne 'Module::Load' } @$used_modules;
    }
    return ($documents, $used_modules);
}

1;
