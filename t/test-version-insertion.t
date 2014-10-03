#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 10;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::Snippets::Meta');}
require_ok('Chronicle::Plugin::Snippets::Meta');


package Chronicle;

our $VERSION              = "cake.free";
our %GLOBAL_TEMPLATE_VARS = ();

package main;


#
#  Ensure things start properly.
#
is( $VERSION,            "cake.free", "Our version is sane" );
is( $Chronicle::VERSION, "cake.free", "The global version is unchanged" );

#
#  We have no global variables
#
is( scalar keys %GLOBAL_TEMPLATE_VARS, 0, "We have no global variables" );
is( $GLOBAL_TEMPLATE_VARS{ 'chronicle_release' },
    undef, "Which means we have no chronicle version definition" );


#
#  Invoke the plugin
#
Chronicle::Plugin::Snippets::Meta::on_initiate();

#
#  Now we should have some defined variables.
#
ok( scalar keys %GLOBAL_TEMPLATE_VARS >= 2,
    "We have some global variables defined" );
is( $GLOBAL_TEMPLATE_VARS{ 'chronicle_version' },
    "cake.free", "Including the chronicle release" );

#
#  And the version is unchanged.
#
is( $VERSION,            "cake.free", "The global version is unchanged" );
is( $Chronicle::VERSION, "cake.free", "The global version is unchanged" );
