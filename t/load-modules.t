#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 5;

BEGIN
{
     use_ok("Chronicle::Plugin::Archived","We could load the module" );
     use_ok("Chronicle::Plugin::Markdown","We could load the module" );
     use_ok("Chronicle::Plugin::Verbose","We could load the module" );

     use_ok("Chronicle::Plugin::Generate::RSS","We could load the module" );
     use_ok("Chronicle::Plugin::Generate::Sitemap","We could load the module" );
}
