#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;
use utf8;
use Test::More tests => 25;
#
#  Load the module.
#
BEGIN {
    use_ok('Chronicle::Plugin::InPlacePosts');
    use_ok('Chronicle::URI');
}


#
#  Create a fake post
#
our %config;
our %data;
$config{ 'input' } = "./blog";

$data{ 'body' }     = "<p>It is true</p>";
$data{ 'date' }     = "10th March 1976";
$data{ 'file' } = "./blog/2015/June/13/cake.post";
$data{ 'link' }     = Chronicle::URI->new("I_lïke_caກ.html");
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
foreach my $key (qw(body date file title))
{
    is( $data{ $key }, $out->{ $key }, "The field is unchanged: $key" );
}

#
#  The only data that should be changed is the link.
#  and should be changed
#  from: 'I_like_cake.html'
#  to:   '2015/June/13/I_like_cake.html'
is( $out->{ link }->as_string,
    '2015/June/13/I_l%C3%AFke_ca%E0%BA%81.html',
    "The link field should be changed" );

# Restore the link and do the same thing again, this time for HFS
Chronicle::URI::i_use_hfs;
$data{ 'link' }     = Chronicle::URI->new("I_lïke_caກ.html");
$out =
  Chronicle::Plugin::InPlacePosts::on_insert( undef,
                                             config => \%config,
                                             data   => \%data
                                           );
is( ref($out), "HASH", "Got a hash" );
is( $out->{ link }->as_string,
    '2015/June/13/I_li%CC%88ke_ca%E0%BA%81.html',
    "Link changed correctly to NFD form" );
