#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 9;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::SkipDrafts');}
require_ok('Chronicle::Plugin::SkipDrafts');


#
#  Create a fake post
#
our %config;
our %data;

$data{ 'title' } = "I like cake";
$data{ 'body' }  = "<p>It is true</p>";
$data{ 'date' }  = "10th March 1976";


#
#  Call the plugin
#
my $out =
  Chronicle::Plugin::SkipDrafts::on_insert( undef,
                                            config => \%config,
                                            data   => \%data
                                          );

#
#  There should be no change to our data.
#
ok( $out, "Returned something." );
is( ref($out), "HASH", "Which was a hash" );
foreach my $key ( keys %data )
{
    is( $data{ $key }, $out->{ $key }, "The field is unchanged: $key" );
}


#
#  OK now make the post a draft, and repeat.
#
#  This time we should get null replies.
#
$data{ 'draft' } = 1;

$out =
  Chronicle::Plugin::SkipDrafts::on_insert( undef,
                                            config => \%config,
                                            data   => \%data
                                          );

#
#  There should be no change to our data.
#
ok( !$out, "Returned empty result for draft-post." );
is( ref($out), '', "This is not a hash" );
