#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Module::Build;
use Getopt::Long;

my $v = '0.0.1';

my $builder = Module::Build->new(
    module_name        => 'Mailbot',
    dist_abstract      => 'Mailbot',
    build_requires     => {},
    configure_requires => { 'Module::Build' => 0.38, },
    requires           => {
        'perl'             => 5.010,
        'Moo'              => 0,
        'LWP::UserAgent'   => 0,
        'Mail::IMAPClient' => 0,
        'MIME::Parser'     => 0,
    },
    add_to_cleanup     => ['Build _build MYMETA.* log/*.log'],
    create_makefile_pl => 'traditional',

    meta_add => {
        no_index => { directory => ['t'], },
        version => $v,
        release_status => 'unstable',
    },
    script_files => ['bin/main.pl'],
    meta_merge   => {
        provides => {
            'Mailbot' => {
                file    => 'lib/Mailbot.pm',
                version => $v,
            },
        },
    },

);

$builder->create_build_script();
