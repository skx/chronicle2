
=head1 NAME

Chronicle::Plugin::Generate::Sitemap - Generate a sitemap automatically

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_terminate> hook that Chronicle provides.

The intention is that the plugin will generate a top-level C<sitemap.xml>
file which contains a link to all your generated blog-pages.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

package Chronicle::Plugin::Generate::Sitemap;

use strict;
use warnings;



=begin doc

Write out a sitemap at the output directory

=end doc

=cut

sub on_terminate
{
    my ( $self, $config, $dbh ) = (@_);

    #
    #  Load our HTML::Template file
    #
    my $tmpl = "";
    while ( my $line = <DATA> )
    {
        $tmpl .= $line;
    }
    return unless ( length($tmpl) );


    #
    #  This is the file we're going to write.
    #
    my $output = $config->{ 'output' } . "/sitemap.xml";

    my $sql = $dbh->prepare("SELECT link FROM blog") or
      die "Failed to prepare: " . $dbh->errstr();

    my $link;
    $sql->execute();

    $sql->bind_columns( undef, \$link );

    my $urls;

    while ( $sql->fetch() )
    {
        push( @$urls, { url => $config->{ 'top' } . $link } );
    }
    $sql->finish();


    my $template = HTML::Template->new( scalarref => \$tmpl );
    $template->param( urls => $urls ) if ($urls);
    $template->param( top => $config->{ 'top' } ) if ( $config->{ 'top' } );

    open( my $handle, ">", $output ) or
      die "Failed to open output file $output - $!";
    print $handle $template->output();
    close($handle);

    if ( $config->{ 'verbose' } )
    {
        print "Wrote " . scalar(@$urls) . " URLS to $output\n";
    }

}

1;

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<urlset
  xmlns="http://www.google.com/schemas/sitemap/0.84"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.google.com/schemas/sitemap/0.84
                      http://www.google.com/schemas/sitemap/0.84/sitemap.xsd">
<!-- tmpl_loop name='urls' --><url>
  <loc><!-- tmpl_var name='url' --></loc>
  <priority>0.50</priority>
  <changefreq>weekly</changefreq>
</url>
<!-- /tmpl_loop --><url>
  <loc><!-- tmpl_var name='top' --></loc>
  <priority>0.75</priority>
  <changefreq>weekly</changefreq>
</url>
</urlset>

