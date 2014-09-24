#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 23;

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
    use_ok( "Chronicle::Plugin::Filter",     "Loaded module" );
    use_ok( "Chronicle::Plugin::Markdown",   "Loaded module" );
    use_ok( "Chronicle::Plugin::PostBuild",  "Loaded module" );
    use_ok( "Chronicle::Plugin::PostSpooler","Loaded module" );
    use_ok( "Chronicle::Plugin::PreBuild",   "Loaded module" );
    use_ok( "Chronicle::Plugin::SkipDrafts", "Loaded module" );
    use_ok( "Chronicle::Plugin::Textile",    "Loaded module" );
    use_ok( "Chronicle::Plugin::Tidy",       "Loaded module" );
    use_ok( "Chronicle::Plugin::YouTube",    "Loaded module" );

    #
    #  Snippets
    #
    use_ok( "Chronicle::Plugin::Snippets::AllTags",     "Loaded module" );
    use_ok( "Chronicle::Plugin::Snippets::Archives",    "Loaded module" );
    use_ok( "Chronicle::Plugin::Snippets::RecentPosts", "Loaded module" );
    use_ok( "Chronicle::Plugin::Snippets::RecentTags",  "Loaded module" );
    use_ok( "Chronicle::Plugin::Snippets::Version",     "Loaded module" );

    #
    #  Generators
    #
    use_ok( "Chronicle::Plugin::Generate::Archive", "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Index",   "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Pages",   "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::RSS",     "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Sitemap", "Loaded module" );
    use_ok( "Chronicle::Plugin::Generate::Tags",    "Loaded module" );
}
