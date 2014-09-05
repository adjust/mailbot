#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use lib 'lib';

use Mailbot;

my $bot = Mailbot->new(
    user   => 'testuser@adeven.com',
    pw     => 'adeven1234#123',
    server => 'imap.gmail.com',
    ssl    => 1,
    port   => 993,
);

$bot->process;

