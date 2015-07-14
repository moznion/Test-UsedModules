package Test::UsedModules::PPIDocument;
use strict;
use warnings;
use utf8;
use PPI::Document;
use PPI::Dumper;
use Test::UsedModules::Constants;

sub new {
    my (undef, $file) = @_;

    my $document = PPI::Document->new($file);
    _remove_unnecessary_tokens($document);
    my $document_str = PPI::Dumper->new($document)->string();
    my ($ppi_document, $load_removed) = _remove_include_sections($document_str);

    my @modules = _fetch_modules_in_module($document_str);

    $document->prune('PPI::Symbol');
    my ($ppi_document_without_symbol) = _remove_include_sections(PPI::Dumper->new($document)->string());

    bless {
        file => $file,
        used_modules => \@modules,
        ppi_document => $ppi_document,
        load_removed => $load_removed,
        ppi_document_without_symbol => $ppi_document_without_symbol,
    };
}

sub _fetch_modules_in_module {
    my ($ppi_document) = @_;
    my @ppi_used_modules = _list_up_modules($ppi_document);

    my @used_modules;
    for my $ppi_used_module (@ppi_used_modules) {
        my $used_module;
        ( $used_module->{type}, $used_module->{name} ) = $ppi_used_module =~ /
            \s*? PPI::Token::Word \s* \'(use|require|load)\' \n
            \s*? PPI::Token::Word \s* \'(.*?)\' \n
        /gxm;

        # Reduce pragmas
        next if grep { $_ eq $used_module->{name} } PRAGMAS;

        ( $used_module->{extend} ) = $ppi_used_module =~ /
            \s*? PPI::Token::Word \s* .*?
            \s*? PPI::Token::Word \s* .*?
            \s*? PPI::\S* \s* \'?(.*?)\'? \n
        /gxm;

        push @used_modules, $used_module;
    }

    return @used_modules;
}

sub _list_up_modules {
    my ($ppi_document) = @_;

    my @ppi_used_modules = $ppi_document =~ /
        PPI::Statement::Include \n
        (
            \s*? PPI::Token::Word \s* \'(?:use|require)\' \s*? \n
            \s*? PPI::Token::Word \s* .*? \n
            (?:.*? \n)?
        )
        \s*? PPI::Token::Structure \s* \';\' \s*? \n
    /gxm;

    my @ppi_loaded_modules = $ppi_document =~ /
        PPI::Statement \n
        (
            \s*? PPI::Token::Word \s* \'load\' \s*? \n
            \s*? PPI::Token::Word \s* .*? \n
            (?:.*? \n)?
        )
        \s*? PPI::Token::Structure \s* \';\' \s*? \n
    /gxm;

    push @ppi_used_modules, @ppi_loaded_modules;

    return @ppi_used_modules;
}

sub _remove_include_sections {
    my ($ppi_document) = @_;
    $ppi_document =~ s/
        PPI::Statement::Include \n
        \s*? PPI::Token::Word \s* \'(?:use|require)\' \s*? \n
        \s*? PPI::Token::Word \s* .*? \n
        (?:.*? \n)?
        \s*? PPI::Token::Structure \s* \';\' \s*? \n
    //gxm;
    my $load_removed = $ppi_document =~ s/
        PPI::Statement \n
        \s*? PPI::Token::Word \s* \'load\' \s*? \n
        \s*? PPI::Token::Word \s* .*? \n
        (?:.*? \n)?
        \s*? PPI::Token::Structure \s* \';\' \s*? \n
    //gxm;
    return ($ppi_document, $load_removed);
}

sub _remove_unnecessary_tokens {
    my ( $document ) = @_;

    my @surplus_tokens = (
        'Operator',
        'Number',
        'Comment',
        'Pod',
        'BOM',
        'Data',
        'End',
        'Prototype',
        'Separator',
        'Whitespace'
    );

    foreach my $surplus_token (@surplus_tokens) {
        $document->prune( 'PPI::Token::' . $surplus_token );
    }

    return $document;
}
1;
