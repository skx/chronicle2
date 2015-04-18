
=head1 NAME

Chronicle::Plugin::Generate::Sitemap - Generate a sitemap automatically

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook that Chronicle provides.

It is responsible for creating the top-level C</sitemap.xml> file
which you use for search engine submission, etc.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut


package Chronicle::Plugin::Generate::Sitemap;


use strict;
use warnings;


our $VERSION = "5.0.9";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating a sitemap for your site.

Unlike all the other plugins it doesn't need to use a template because
it can keep track of each distinct page which has been generated.

The generated sitemap file includes:

=over 8

=item All the distinct posts ever made.

=item A link to the tag-index.

=item A link to the archive-index.

=back

If you merge any static pages, such as C</about/> then these will not be
included in the map.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };


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


    #
    #  Load the template
    #
    my $template = Chronicle::load_template( undef, $tmpl );
    $template->param( urls => $urls ) if ($urls);
    $template->param( top => $config->{ 'top' } ) if ( $config->{ 'top' } );

    open( my $handle, ">:encoding(UTF-8)", $output ) or
      die "Failed to open output file $output - $!";
    print $handle $template->output();
    close($handle);

    if ( $config->{ 'verbose' } )
    {
        print "Wrote " . ( $urls ? scalar(@$urls) : 0 ) . " URLS to $output\n";
    }

}


1;


=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version,
or

b) the Perl "Artistic License".

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut


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
<url>
  <loc><!-- tmpl_var name='top' -->/archive/</loc>
  <priority>0.50</priority>
  <changefreq>weekly</changefreq>
</url>
<url>
  <loc><!-- tmpl_var name='top' -->/tags/</loc>
  <priority>0.50</priority>
  <changefreq>weekly</changefreq>
</url>
</urlset>

