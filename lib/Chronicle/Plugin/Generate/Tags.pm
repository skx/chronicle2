
=head1 NAME

Chronicle::Plugin::Generate::Tags - Generate tags pages.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level C</tags/> hierarchy.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Generate::Tags;


use strict;
use warnings;


our $VERSION = "5.1.6";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating the tag-output, which
includes two sets of pages:

=over 8

=item C</tags/index.html>

This is created using the C<tag_index.tmpl> theme-template, and contains
a list of all the tags which have ever been used.

=item C</tags/$tag/index.html>

This is created for each distinct tag, from the theme-template
C<tag.tmpl>

=back

If either template is missing then this plugin will skip that part of
the generation.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };


    _outputTags( $config, $dbh );

    _outputTagCloud( $config, $dbh );
}


=head2 _outputTags

Output a page (`output/tags/$tag/index.html`) for each distinct tag
we've ever used.

=cut

sub _outputTags
{
    my ( $config, $dbh ) = (@_);

    my $all = $dbh->prepare(
        "SELECT DISTINCT(name) FROM tags GROUP BY name ORDER by name COLLATE nocase"
      ) or
      die "Failed to find all tags";
    my $ids = $dbh->prepare(
        "SELECT DISTINCT(a.blog_id) FROM tags AS a JOIN blog AS b WHERE ( a.blog_id = b.id AND a.name=? ) ORDER BY b.date DESC"
      ) or
      die "Failed to find all blog posts with given tag";

    $all->execute() or die "Failed to execute:" . $dbh->errstr();
    my $tag;
    $all->bind_columns( undef, \$tag );


    while ( $all->fetch() )
    {
        #
        #  The output file to generate
        #
        my $index = $config->{ 'index_filename' } || "index.html";

        $config->{ 'verbose' } &&
          print "Creating : $config->{'output'}/tags/$tag/$index\n";

        File::Path::make_path( "$config->{'output'}/tags/$tag",
                               {  verbose => 0,
                                  mode    => 0755,
                               } );

        #
        #  Data for HTML::Template
        #
        my $entries;

        #
        #  For this tag get the posts associated with it.
        #
        $ids->execute($tag) or die "Failed to execute: " . $dbh->errstr();
        my $id;
        $ids->bind_columns( undef, \$id );

        while ( $ids->fetch() )
        {
            my $post =
              Chronicle::getBlog( dbh    => $dbh,
                                  id     => $id,
                                  config => $config
                                );
            if ( $config->{ 'lower-case' } )
            {
                $post->{ 'link' } = lc( $post->{ 'link' } );
            }

            push( @$entries, $post );
        }


        my $c = Chronicle::load_template("tag.tmpl");
        return unless ($c);

        $c->param( top     => $config->{ 'top' } );
        $c->param( entries => $entries ) if ($entries);
        $c->param( tag     => $tag );
        open my $handle, ">:encoding(UTF-8)",
          "$config->{'output'}/tags/$tag/$index" or
          die "Failed to open";
        print $handle $c->output();
        close $handle;

    }


    #
    #  We're all done.
    #
    $all->finish();
    $ids->finish();

}



=head2 _outputTagCloud

Output `output/tags/index.html` containing a complete tag-cloud of the
tags we've ever used.

=cut

sub _outputTagCloud
{
    my ( $config, $dbh ) = (@_);

    my $tags;

    # Default sizing options
    my $min  = $config->{ 'tag_cloud_size_min' }  || 5;
    my $max  = $config->{ 'tag_cloud_size_max' }  || 60;
    my $step = $config->{ 'tag_cloud_size_step' } || 5;

    #
    # Now the tags.
    #
    my $sql = $dbh->prepare(
        "SELECT DISTINCT(name),COUNT(name) AS runningtotal FROM tags GROUP BY name COLLATE nocase"
      ) or
      die "Failed to prepare tag cloud";
    $sql->execute() or die "Failed to execute: " . $dbh->errstr();

    my ( $tag, $count );
    $sql->bind_columns( undef, \$tag, \$count );

    #
    # Process the results.
    #
    while ( $sql->fetch() )
    {
        my $size = $count * $step + $min;
        $size = $max if ( $size > $max );

        push( @$tags,
              {  tag   => $tag,
                 count => $count,
                 tsize => $size
              } );

    }
    $sql->finish();


    #
    #  The output file to generate
    #
    my $index      = $config->{ 'index_filename' } || "index.html";
    my $index_dir  = "$config->{'output'}/tags/";
    my $index_path = "${index_dir}${index}";

    print "Creating : $index_path\n" if $config->{ 'verbose' };

    File::Path::make_path( $index_dir, { verbose => 0, mode => 0755 } )
      unless -d $index_dir;

    my $c = Chronicle::load_template("tag_index.tmpl");
    return unless ($c);

    $c->param( all_tags => $tags ) if ($tags);
    $c->param( top => $config->{ 'top' } );

    open my $handle, ">:encoding(UTF-8)", $index_path or
      die "Failed to open `$index_path': $!";
    print $handle $c->output();
    close $handle;
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
