#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use Mailbot;
use YAML qw/LoadFile/;

my $config = LoadFile('config.yml');

my $bot = Mailbot->new(
    user        => $config->{user},
    pw          => $config->{pw},
    server      => $config->{server},
    ssl         => $config->{ssl},
    port        => $config->{port},
    allowedFrom => $config->{allowedSender},
);

$bot->process;

