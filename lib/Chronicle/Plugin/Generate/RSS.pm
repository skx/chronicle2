
=head1 NAME

Chronicle::Plugin::Generate::RSS - Generate a RSS feed for the blog.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level RSS-feed for your blog,
which will be located at C</index.rss>.

If there is a file named C<index.rss> in the currently-selected
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


our $VERSION = "5.0.9";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating the RSS-feed of your
blog site, via the theme-provided template C<index.rss>.

If there is no C<index.rss> template present in the theme then a default
will be used.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{dbh};
    my $config = $args{config};

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


    $config->{verbose} &&
      print "Creating : $config->{output}/index.rss\n";


    #
    #  If there is a theme-provided file then use it.
    #
    my $c = Chronicle::load_template("index.rss");

    #
    #  If not then we're going to use our default, which is
    # contained in the __DATA__ section of this very-module.
    #
    if ( !$c )
    {
        my $tmpl = "";
        while ( my $line = <DATA> )
        {
            $tmpl .= $line;
        }

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
    $c->param( top => $config->{top} );
    $c->param( entries => $entries ) if ($entries);

    #
    #  Output the rendered template.
    #
    open( my $handle, ">:encoding(UTF-8)", "$config->{output}/index.rss" ) or
      die "Failed to open";
    print $handle $c->output();
    close($handle);


    #
    #  Show the number of entries written if we're being verbose.
    #
    if ( $config->{verbose} && $entries )
    {
        print "Wrote " . scalar(@$entries) .
          " items to $config->{output}/index.rss\n";
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
<?xml version="1.0" encoding="utf-8"?>
<rss version='2.0' xmlns:lj='http://www.livejournal.org/rss/lj/1.0/' xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
		<title><!-- tmpl_var name='blog_title' escape='html' --></title>
		<description><!-- tmpl_var name='blog_subtitle' escape='html' --></description>
                <link><!-- tmpl_var name='top' --></link>
                <atom:link href="<!-- tmpl_var name='top' -->index.rss" rel="self" type="application/rss+xml" />
	<!-- tmpl_loop name="entries" -->
	<item>
		<title><!-- tmpl_var name="title" escape='html' --></title>
		<link><!-- tmpl_var name='top' --><!-- tmpl_var name='link' --></link>
		<guid isPermaLink="true"><!-- tmpl_var name='top' --><!-- tmpl_var name='link' --></guid>
                <pubDate><!-- tmpl_var name='date' --></pubDate>
		<description><!-- tmpl_var name="body" escape='html' --></description>
	</item>
	<!-- /tmpl_loop -->
        </channel>
</rss>
