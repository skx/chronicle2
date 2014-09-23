#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 3;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::Tidy');}
require_ok('Chronicle::Plugin::Tidy');


#
#  Create a fake blog-post
#
my %data;
$data{ 'body' }  = "<P>This paragraph is unclosed";
$data{ 'title' } = "Irrelevent";


#
#  Run through the plugin and verify that the input hasn't changed.
#
#  (Because no "format" key exists in the hash.)
#
my $out = Chronicle::Plugin::Tidy::on_insert( undef, data => \%data );

is( $out->{ 'body' },
    "<p>This paragraph is unclosed</p>",
    "The trailing P was fixed" );
