#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 10;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Config::Reader');}
require_ok('Chronicle::Config::Reader');



my $c = Chronicle::Config::Reader->new();
isa_ok( $c, "Chronicle::Config::Reader", "Construction succeeds" );


#
#  The variables we'll update via the config
#
my %VARS;
$VARS{ 'foo' } = 'bar';


#
#  Setting a new key.
#
$c->parseLine( \%VARS, "steve = kemp " );
is( $VARS{ 'steve' }, "kemp", "Setting a single key works" );


#
#  Unsetting a previously set value.
#
is( $VARS{ 'foo' }, "bar", "Initial value is OK" );
$c->parseLine( \%VARS, "foo =" );
is( $VARS{ 'foo' }, "", "The value has been removed" );
$c->parseLine( \%VARS, "foo = meow" );
is( $VARS{ 'foo' }, "meow", "The value has been updated" );

#
#  Expand ENV
#
SKIP:
{
    skip "No USER environment setup", 1 unless ( $ENV{ 'USER' } );

    $c->parseLine( \%VARS, 'user = $USER' );
    is( $VARS{ 'user' }, $ENV{ 'USER' }, "Environmental variable updated" );
}

#
#  Test for command.
#
SKIP:
{
    skip "No /bin/ls", 2 unless ( -x "/bin/ls" );

    $c->parseLine( \%VARS, 'ls = `/bin/ls /bin/ls`' );
    ok( $VARS{ 'ls' }, "Command expansion resulted in something" );
    ok( $VARS{ 'ls' } =~ /ls/i, "Command contains something" );

}
