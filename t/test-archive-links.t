#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 9;

#
#  Load the module.
#
BEGIN {
    use_ok('Chronicle::Plugin::Archived');
    use_ok('Chronicle::URI');
}


#
#  Create some data
#
my %data;
my $link = "/some_blog_post.html";

$data{ 'body' } = "This is **bold**";
$data{ 'link' } = Chronicle::URI->new($link);
$data{ 'date' } = scalar( localtime() );



#
#  Run through the plugin and verify the link has a date-prefix now
#
my $out = Chronicle::Plugin::Archived::on_insert( undef, data => \%data );


#
#  The body, date, and title won't have changed.
#
foreach my $key (qw! body date title !)
{
    is( $out->{ $key }, $data{ $key }, "The blog field is unchanged $key" );
}


#
#  But the link should have done
#
isnt( $out->{ 'link' }->as_string, $link, "The link is updated" );


#
#  We should expect NNNN/MM/$title
#
my $YEAR = substr( $data{ 'link' }->as_string, 0, 4 );
my $MON  = substr( $data{ 'link' }->as_string, 5, 2 );

#
#  Test they're numeric.
#
ok( $YEAR =~ /^([0-9]+)$/, "Year is numeric" );
ok( $MON  =~ /^([0-9]+)$/, "Month is numeric" );

#
# And the link should make sense - so it should have todays date in it.
#
# FInd the current date.
#
my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
$year += 1900;
$mon  += 1;

#
#  Ensure the month is zero-padded if appropriate.
#
$mon = sprintf( "%02d", $mon );

is( $out->{ 'link' }->as_string,
    "$year/$mon/$link", "We got the link we expected: " . $out->{'link'}->as_string );
