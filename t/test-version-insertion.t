#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 10;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::Version');}
require_ok('Chronicle::Plugin::Version');
BEGIN {use_ok('Chronicle::Plugin::Version');}
require_ok('Chronicle::Plugin::Version');


package Chronicle;

our $VERSION              = "cake.free";
our %GLOBAL_TEMPLATE_VARS = ();

package main;


#
#  Ensure things start properly.
#
is( $VERSION,            "cake.free", "Our version is sane" );
is( $Chronicle::VERSION, "cake.free", "The global version is unchanged" );
is( $GLOBAL_TEMPLATE_VARS{ 'release' },
    undef, "But the global variable is empty" );


#
#  Load the plugin
#
Chronicle::Plugin::Version::on_initiate();

#
#  Now the release variable should be populated.
#
is( $GLOBAL_TEMPLATE_VARS{ 'release' },
    "cake.free", "Now the global variable is empty" );

#
#  And the version is unchanged.
#
is( $VERSION,            "cake.free", "The global version is unchanged" );
is( $Chronicle::VERSION, "cake.free", "The global version is unchanged" );
