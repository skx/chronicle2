#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 18;

BEGIN
{

    #
    #  Helpers
    #
    use_ok( "Chronicle::Config::Reader", "Loaded module" );

    #
    #  General plugins
    #
    use_ok( "Chronicle::Plugin::Archived",   "Loaded module" );
    use_ok( "Chronicle::Plugin::DBTweak",    "Loaded module" );
    use_ok( "Chronicle::Plugin::Markdown",   "Loaded module" );
    use_ok( "Chronicle::Plugin::Textile",    "Loaded module" );
    use_ok( "Chronicle::Plugin::Verbose",    "Loaded module" );
    use_ok( "Chronicle::Plugin::Version",    "Loaded module" );
    use_ok( "Chronicle::Plugin::SkipDrafts", "Loaded module" );

    #
    #  Snippets
    #
    use_ok( "Chronicle::Plugin::Snippets::AllTags",     "Loaded module" );
    use_ok( "Chronicle::Plugin::Snippets::Archives",    "Loaded module" );
    use_ok( "Chronicle::Plugin::Snippets::RecentTags",  "Loaded module" );
    use_ok( "Chronicle::Plugin::Snippets::RecentPosts", "Loaded module" );

    #
    #  Generators
    #
    use_ok( "Chronicle::Plugin::Generate::Archive", "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Pages",   "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Index",   "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::RSS",     "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Tags",    "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Sitemap", "Loaded module" );
}
