#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 4;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::TruncatedBody');}
require_ok('Chronicle::Plugin::TruncatedBody');


#
#  Create some data
#
my %data;
$data{ 'body' } =
  "Text before the cut
__CUT__

text after the cut";

 
 
    my $out =
      Chronicle::Plugin::TruncatedBody::on_insert( undef, data => \%data );

    is( $out->{ 'body' },"Text before the cut


text after the cut");
    is( $out->{ 'truncatedbody' },"Text before the cut

<a href=''>Read More</a>");

