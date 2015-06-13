#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;
use Test::More tests => 23;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::InPlacePosts');}
require_ok('Chronicle::Plugin::InPlacePosts');


#
#  Create a fake post
#
our %config;
our %data;
$config{ 'input' } = "./blog";

$data{ 'body' }     = "<p>It is true</p>";
$data{ 'date' }     = "10th March 1976";
$data{ 'filename' } = "./blog/2015/June/13/cake.post";
$data{ 'link' }     = "I_like_cake.html";
$data{ 'title' }    = "I like cake";


#
#  Call the plugin
#
my $out =
  Chronicle::Plugin::InPlacePosts::on_insert( undef,
                                             config => \%config,
                                             data   => \%data
                                           );

#
#  There should be no change to our data as there is no entry_inplace.
#

ok( $out, "Returned something." );
is( ref($out), "HASH", "Which was a hash" );
foreach my $key ( keys %data )
{
    is( $data{ $key }, $out->{ $key }, "The field is unchanged: $key" );
}


#
#  There should be no change to our data as entry_inplace is false
#
$config{ 'entry_inplace' } = 0;

#
#  Call the plugin
#
$out =
  Chronicle::Plugin::InPlacePosts::on_insert( undef,
                                             config => \%config,
                                             data   => \%data
                                           );

ok( $out, "Returned something." );
is( ref($out), "HASH", "Which was a hash" );
foreach my $key ( keys %data )
{
    is( $data{ $key }, $out->{ $key }, "The field is unchanged: $key" );
}

#
#  OK now make the chronicle generate the page in place.
#
$config{ 'entry_inplace' } = 1;

#
#  Call the plugin
#
$out =
  Chronicle::Plugin::InPlacePosts::on_insert( undef,
                                             config => \%config,
                                             data   => \%data
                                           );

ok( $out, "Returned something." );
is( ref($out), "HASH", "Which was a hash" );
foreach my $key (qw(body date filename title))
{
    is( $data{ $key }, $out->{ $key }, "The field is unchanged: $key" );
}

#
#  The only data that should be changed is the link.
#  and should be changed
#  from: 'I_like_cake.html'
#  to:   '2015/June/13/I_like_cake.html'
is( '2015/June/13/I_like_cake.html',
    $out->{ link },
    "The link field should be changed" );
