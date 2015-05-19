#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 12;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::TruncatedBody');}
require_ok('Chronicle::Plugin::TruncatedBody');


#
#  Create some data
#


#
#  This tests the correct form of one __CUT__
#

my %correct_cut_data;
$correct_cut_data{ 'body' } = "Text before the cut
__CUT__

text after the cut";


my $out = Chronicle::Plugin::TruncatedBody::on_insert( undef,
                                                   data => \%correct_cut_data );

is( $out->{ body }, 'Text before the cut

text after the cut', 'one cut body'
);

is( $out->{ truncatedbody }, "Text before the cut

<a href=\"\">Read More</a>", 'one cut truncatedbody'
);


#
#  This tests the incorrect form of one __CUT__
#

my %incorrect_cut_data;
$incorrect_cut_data{ 'body' } = "Text before the cut
 __CUT__

text after the cut";


$out = Chronicle::Plugin::TruncatedBody::on_insert( undef,
                                                 data => \%incorrect_cut_data );

is( $out->{ body }, 'Text before the cut
 __CUT__

text after the cut', 'one incorrect cut body'
);

is( $out->{ truncatedbody }, undef, 'one incorrect cut truncatedbody' );


#
#  This tests with two __CUT__'s with the both cut being correct
#

my %two_cut_data;
$two_cut_data{ 'body' } = "Text before the cut
__CUT__

text inbetween the cuts

__CUT__
text after the cut";


$out =
  Chronicle::Plugin::TruncatedBody::on_insert( undef, data => \%two_cut_data );

is( $out->{ body }, 'Text before the cut

text inbetween the cuts

__CUT__
text after the cut', 'two cut body'
);

is( $out->{ truncatedbody }, "Text before the cut

<a href=\"\">Read More</a>", 'two cut truncatedbody'
);


#
#  This tests with two __CUT__'s with the first cut being correct
#

my %two_cut_data_1;
$two_cut_data_1{ 'body' } = "Text before the cut
__CUT__

text inbetween the cuts

 __CUT__
text after the cut";


$out = Chronicle::Plugin::TruncatedBody::on_insert( undef,
                                                    data => \%two_cut_data_1 );

is( $out->{ body }, 'Text before the cut

text inbetween the cuts

 __CUT__
text after the cut', 'two cut body 1'
);

is( $out->{ truncatedbody }, "Text before the cut

<a href=\"\">Read More</a>", 'two cut truncatedbody 1'
);

#
#  This tests with two __CUT__'s with the second cut being correct
#

my %two_cut_data_2;
$two_cut_data_2{ 'body' } = "Text before the cut
 __CUT__

text inbetween the cuts

__CUT__
text after the cut";


$out = Chronicle::Plugin::TruncatedBody::on_insert( undef,
                                                    data => \%two_cut_data_2 );

is( $out->{ body }, 'Text before the cut
 __CUT__

text inbetween the cuts

text after the cut', 'two cut body 2'
);

is( $out->{ truncatedbody }, "Text before the cut
 __CUT__

text inbetween the cuts


<a href=\"\">Read More</a>", 'two cut truncatedbody 2'
);




