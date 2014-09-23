#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 6;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::YouTube');}
require_ok('Chronicle::Plugin::YouTube');


#
#  Create some data
#
my %data;
$data{ 'date' } = scalar( localtime() );
$data{ 'body' } =<<EOF;
This is my body.

<youtube>testme</youtube>

<youtube>1234</youtube> <youtube>XXXX</youtube>
EOF


#
#  Load the plugin.
#
my $out = Chronicle::Plugin::YouTube::on_insert( undef, data => \%data );
$out = $out->{'body'};

#
#  We shouldn't have the "</youtube>" tag present any more
#
ok( $out !~ /<\/youtube>/, "The <youtube></youtube> links are removed" );

#
#  Bud we should have three links
#
foreach my $link ( qw! testme 1234 XXXX ! )
{
    ok( $out =~ /embed\/$link/, "We found a sane embedded link" );
}

