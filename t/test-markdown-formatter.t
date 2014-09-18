#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 8;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::Markdown');}
require_ok('Chronicle::Plugin::Markdown');
BEGIN {use_ok('Chronicle::Plugin::Markdown');}
require_ok('Chronicle::Plugin::Markdown');


#
#  Create some data
#
my %data;
$data{ 'body' } = "This is **bold**";


#
#  Run through the plugin and verify that the input hasn't changed.
#
#  (Because no "format" key exists in the hash.)
#
my $f = Chronicle::Plugin::Markdown::modify_entry( undef, \%data );
is( $f->{ 'body' }, $data{ 'body' },
    "Body is unchanged with no formatter set" );

#
#  Now we'll set a format type, and ensure that this has caused
# the expected expansion to happen.
#
foreach my $type (qw! markdown MARKDOWN MarkDoWN !)
{
    $data{ 'format' } = $type;

    my $out = Chronicle::Plugin::Markdown::modify_entry( undef, \%data );

    is( $out->{ 'body' },
        "<p>This is <strong>bold</strong></p>\n",
        "Body has been processed with formatter:" . $type );
}
