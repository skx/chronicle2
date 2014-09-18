#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 12;

BEGIN
{
    use_ok( "Chronicle::Plugin::Archived", "We could load the module" );
    use_ok( "Chronicle::Plugin::Timer",    "We could load the module" );
    use_ok( "Chronicle::Plugin::Markdown", "We could load the module" );
    use_ok( "Chronicle::Plugin::Textile",  "We could load the module" );
    use_ok( "Chronicle::Plugin::Verbose",  "We could load the module" );
    use_ok( "Chronicle::Plugin::Version",  "We could load the module" );

    use_ok( "Chronicle::Plugin::Generate::Archive",
            "We could load the module" );
    use_ok( "Chronicle::Plugin::Generate::Pages", "We could load the module" );
    use_ok( "Chronicle::Plugin::Generate::Index", "We could load the module" );
    use_ok( "Chronicle::Plugin::Generate::RSS",   "We could load the module" );
    use_ok( "Chronicle::Plugin::Generate::Tags",  "We could load the module" );
    use_ok( "Chronicle::Plugin::Generate::Sitemap",
            "We could load the module" );
}
