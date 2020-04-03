#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 5;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::PostSpooler');}
require_ok('Chronicle::Plugin::PostSpooler');



#
#  Create a fake blog-post
#
my %data;
$data{ 'body' }    = "This is **bold**";
$data{ 'publish' } = scalar( localtime() );
$data{ 'publish' } =~ s/(20[0-9]+)/2099/g;


#
#  Run through the plugin and verify the the post won't be added.
#
my $out = Chronicle::Plugin::PostSpooler::on_insert( undef, data => \%data );
is( $out, undef, "The future post won't be made live" );

#
#  OK now try a post that is in the past.
#
$data{ 'publish' } =~ s/2099/1999/g;

#
#  This should be present.
#
$out = Chronicle::Plugin::PostSpooler::on_insert( undef, data => \%data );
is( $out->{ 'publish' },
    undef, "Thie publish field was removed in a post to be published." );
ok( $out->{ 'date' } =~ /1999/, "The post is dated in the past, as expected." );
