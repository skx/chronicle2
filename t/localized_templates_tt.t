#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;
use Test::More;
use FindBin;

# If you need to change the .po file, recompile with:
#   cd themes/test_theme/locale/de_DE.UTF-8/LC_MESSAGES/
#   msgfmt chronicle2-theme.po -o chronicle2-theme.mo

#
#  Load the modules.
#
eval 'use Template';
if($@) {
    plan skip_all => 'Template Toolkit not available';
    exit 0;
}
use_ok('Chronicle::Template');

my $TMPL = '[% loc__nx("One foo", "{n} foos", foo, n => foo) %]';

my %tmpl_args = ( type        => 'TT',
                  theme_dir   => "${FindBin::Bin}/themes/",
                  theme       => 'test_theme',
                  tmpl_string => $TMPL,
                );

# Test the default with an unknown locale
$ENV{ LANGUAGE } = 'zh_TW.UTF-8';
my $tmpl = Chronicle::Template->create(%tmpl_args);
ok( $tmpl->isa('Chronicle::Template::TT'),
    "Got a Chronicle::Template::TT object" );
$tmpl->param( foo => 1 );
is( $tmpl->output, "One foo", "Correct default singular" );
$tmpl->param( foo => 5 );
is( $tmpl->output, "5 foos", "Correct default plural" );

# Test de_DE which has a mesage catalog
$ENV{ LANGUAGE } = 'de_DE.UTF-8';
$tmpl = Chronicle::Template->create(%tmpl_args);
ok( $tmpl->isa('Chronicle::Template::TT'),
    "Got a Chronicle::Template::TT object for de_DE" );
$tmpl->param( foo => 1 );
is( $tmpl->output, "Ein foo", "Correct singular for de_DE" );
$tmpl->param( foo => 5 );
is( $tmpl->output, "Der foosen 5", "Correct *cough* plural for de_DE" );
done_testing;
