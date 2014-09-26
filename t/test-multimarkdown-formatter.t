#!/usr/bin/perl -I../lib/ -Ilib/

use strict;
use warnings;

use Test::More tests => 6;

#
#  Load the module.
#
BEGIN {use_ok('Chronicle::Plugin::MultiMarkdown');}
require_ok('Chronicle::Plugin::MultiMarkdown');


#
#  Create some data
#
my %data;
$data{ 'body' } =
  "Here is some text containing a footnote[^somesamplefootnote]. You can then continue your thought...

[^somesamplefootnote]: Here is the text of the footnote itself.";


#
#  Run through the plugin and verify that the input hasn't changed.
#
#  (Because no "format" key exists in the hash.)
#
my $f = Chronicle::Plugin::MultiMarkdown::on_insert( undef, data => \%data );
is( $f->{ 'body' }, $data{ 'body' },
    "Body is unchanged with no formatter set" );

#
#  Now we'll set a format type, and ensure that this has caused
# the expected expansion to happen.
#
foreach my $type (qw! multimarkdown MULTIMARKDOWN MuLtIMarkDoWN !)
{
    $data{ 'format' } = $type;

    my $out =
      Chronicle::Plugin::MultiMarkdown::on_insert( undef, data => \%data );

    is( $out->{ 'body' },
        '<p>Here is some text containing a footnote<a href="#fn:somesamplefootnote" id="fnref:somesamplefootnote" class="footnote">1</a>. You can then continue your thought...</p>

<div class="footnotes">
<hr />
<ol>

<li id="fn:somesamplefootnote"><p>Here is the text of the footnote itself.<a href="#fnref:somesamplefootnote" class="reversefootnote">&#160;&#8617;</a></p></li>

</ol>
</div>
',
        "Body has been processed with formatter:" . $type
      );
}
