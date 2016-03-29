
=head1 NAME

Chronicle::Plugin::Generate::RSS - Generate a RSS feed for the blog.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level RSS-feed for your blog,
which will be located at C</rss.tmpl>.

If there is a file named C<rss.tmpl> in the currently-selected
theme it will be used as the template for the generation of the
feed, otherwise a default RSS-template will be used, which will
come from this module.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut


package Chronicle::Plugin::Generate::RSS;


use strict;
use warnings;


our $VERSION = "5.1.4";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating the RSS-feed of your
blog site, via the theme-provided template C<rss.tmpl>.

If there is no C<rss.tmpl> template present in the theme then a default
will be used.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    my $recent = $dbh->prepare(
        "SELECT id FROM blog ORDER BY date DESC LIMIT 0,$config->{'rss-count'}")
      or
      die "Failed to find recent posts";

    $recent->execute() or die "Failed to execute:" . $dbh->errstr();
    my $id;
    $recent->bind_columns( undef, \$id );


    my $entries;

    while ( $recent->fetch() )
    {
        push( @$entries,
              Chronicle::getBlog( dbh    => $dbh,
                                  id     => $id,
                                  config => $config
                                ) );
    }
    $recent->finish();


    $config->{ 'verbose' } &&
      print "Creating : $config->{'output'}/index.rss\n";


    #
    #  If there is a theme-provided file then use it.
    #
    my $c = Chronicle::load_template("rss.tmpl");

    #
    #  If not then we're going to use our default, which is
    # contained in the __DATA__ section of this very module.
    #
    if ( !$c )
    {
        my $tmpl = do { local $/; <DATA> };

        #
        #  If there is no template read then something weird has happened
        #
        return unless ( $tmpl && length($tmpl) );

        #
        #  Load the template
        #
        $c = Chronicle::load_template( undef, $tmpl );
    }


    #
    #  At this point we should have one of the two templates loaded,
    # but if not .. we'll just return.
    #
    return unless ($c);


    #
    #  Add the entries.
    #
    $c->param( top => $config->{ 'top' } );
    $c->param( entries => $entries ) if ($entries);

    #
    #  Output the rendered template.
    #
    my $rss_output = "$config->{'output'}/index.rss";
    open my $handle, ">:encoding(UTF-8)", $rss_output
        or die "Failed to open `$rss_output': $!";
    print $handle $c->output();
    close $handle;


    #
    #  Show the number of entries written if we're being verbose.
    #
    if ( $config->{ 'verbose' } && $entries )
    {
        print "Wrote " . scalar(@$entries) .
          " items to $rss_output\n";
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
<?xml version="1.0"?>
<rdf:RDF
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:foaf="http://xmlns.com/foaf/0.1/"
 xmlns:content="http://purl.org/rss/1.0/modules/content/"
 xmlns="http://purl.org/rss/1.0/"
>
<channel rdf:about="<!-- tmpl_var name='top' -->">
<title><!-- tmpl_var name='blog_title' escape='html' --></title>
<link><!-- tmpl_var name='top' --></link>
<description><!-- tmpl_var name='blog_subtitle' escape='html' --></description>
<items>
 <rdf:Seq>
<!-- tmpl_loop name="entries" -->
  <rdf:li rdf:resource="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' -->"/>
<!-- /tmpl_loop name="entries" -->
 </rdf:Seq>
</items>
</channel>

<!-- tmpl_loop name="entries" -->
<item rdf:about="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' -->">
<title><!-- tmpl_var name='title' escape='html' --></title>
<link><!-- tmpl_var name='top' --><!-- tmpl_var name='link' --></link>
<content:encoded><!-- tmpl_var name="body" escape='html' --></content:encoded>
<dc:date><!-- tmpl_var name='iso_8601' --></dc:date>
</item>
<!-- /tmpl_loop name='entries' -->
</rdf:RDF>
