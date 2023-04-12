#!/usr/bin/env perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Perl::CodeGen::GPT4',
    AUTHOR       => 'Nelson Ferraz <nferraz@gmail.com>',
    VERSION_FROM => 'bin/codegen-gpt4.pl',
    ABSTRACT     => 'Perl code generator based on GPT-4',
    LICENSE      => 'artistic_2',
    PREREQ_PM    => {
        'OpenAI::API' => 0,
    },
    EXE_FILES => ['bin/codegen-gpt4.pl'],
);
