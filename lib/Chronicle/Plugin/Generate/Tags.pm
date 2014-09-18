
package Chronicle::Plugin::Generate::Tags;

use strict;
use warnings;


=begin doc

This method is called when all the parsing is done, and we use this
to generate the tag-output pages.

=end doc

=cut

sub on_terminate
{
    my ( $self, $config, $dbh ) = (@_);

    outputTags( $config, $dbh );

    outputTagCloud( $config, $dbh );
}


=begin doc

Output a page (`output/tags/$tag/index.html`) for each distinct tag
we've ever used.

=end doc

=cut

sub outputTags
{
    my ( $config, $dbh ) = (@_);

    my $all = $dbh->prepare("SELECT DISTINCT(name) FROM tags") or
      die "Failed to find all tags";
    my $ids =
      $dbh->prepare("SELECT DISTINCT(a.blog_id) FROM tags AS a JOIN blog AS b WHERE ( a.blog_id = b.id AND a.name=? ) ORDER BY b.date DESC") or
      die "Failed to find all blog posts with given tag";

    $all->execute() or die "Failed to execute:" . $dbh->errstr();
    my $tag;
    $all->bind_columns( undef, \$tag );

    while ( $all->fetch() )
    {

        # skip if it exists.
        next if ( -e $config->{ 'output' } . "/tags/$tag" );

        $config->{ 'verbose' } &&
          print "Creating : $config->{'output'}/tags/$tag/index.html\n";

        File::Path::make_path( "$config->{'output'}/tags/$tag",
                               {  verbose => 0,
                                  mode    => oct("755"),
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
            push( @$entries, Chronicle::getBlog( $dbh, $id ) );
        }




        my $c = Chronicle::load_template("tag.tmpl");
        $c->param( top     => $config->{ 'top' } );
        $c->param( entries => $entries ) if ($entries);
        $c->param( tag     => $tag );
        open( my $handle, ">:encoding(UTF-8)",
              "$config->{'output'}/tags/$tag/index.html" ) or
          die "Failed to open";
        print $handle $c->output();
        close($handle);

    }


    #
    #  We're all done.
    #
    $all->finish();
    $ids->finish();

}



=begin doc

Output `output/tags/index.html` containing a complete tag-cloud of the
tags we've ever used.

=end doc

=cut

sub outputTagCloud
{
    my ( $config, $dbh ) = (@_);

    my $tags;

    #
    # Now the tags.
    #
    my $sql = $dbh->prepare(
        'SELECT DISTINCT(name),COUNT(name) AS runningtotal FROM tags GROUP BY name ORDER BY name'
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
        my $size = $count * 5 + 5;
        if ( $size > 60 ) {$size = 60;}

        push( @$tags,
              {  tag   => $tag,
                 count => $count,
                 tsize => $size
              } );

    }
    $sql->finish();


    $config->{ 'verbose' } &&
      print "Creating : $config->{'output'}/tags/index.html\n";

    my $c = Chronicle::load_template("cloud.tmpl");
    $c->param( all_tags => $tags );
    $c->param( top      => $config->{ 'top' } );
    open( my $handle, ">", "$config->{'output'}/tags/index.html" ) or
      die "Failed to open";
    print $handle $c->output();
    close($handle);
}



1;
