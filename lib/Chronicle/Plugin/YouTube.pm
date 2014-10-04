
=head1 NAME

Chronicle::Plugin::YouTube - Allow Youtube videos to be embedded.

=head1 DESCRIPTION

This plugin allows simple markup to be expanded into inline YouTube
videos.  The tag "youtube" will also be automatically applied to
the appropriate entries.

For example the following blog-post will contain an inline video:

=for example begin

    Title: My Title
    Date: 10th March 2014

    <youtube>XXXXX</youtube>

=for example end

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::YouTube;


use strict;
use warnings;


our $VERSION = "5.0.7";


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

This plugin will look for lines of the form:

=for example begin

    <youtube>$ID</youtube>

=for example end

Any such link will be replaced by an inline version of the video,
and the blog-post will have the tag value updated to include C<youtube>.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $conf = $args{ 'config' };
    my $data = $args{ 'data' };

    # get the body
    my $old_body = $data->{ 'body' };
    my $new_body = "";

    my $updated = 0;

    # tokenize by line
    foreach my $line ( split( /[\r\n]/, $old_body ) )
    {
        while ( $line =~ /^(.*)<youtube>([^<]+)<\/youtube>(.*)$/i )
        {
            my $pre  = $1;
            my $vid  = $2;
            my $post = $3;

            $line = $1;
            $line .= <<EOF;
<iframe src="http://www.youtube.com/embed/$vid" width="560" height="315" frameborder="0" allowfullscreen></iframe>
EOF
            $line .= $3;

            $updated += 1;
        }

        $new_body .= $line . "\n";
    }

    if ($updated)
    {
        $data->{ 'body' } = $new_body;

        if ( $data->{ 'tags' } )
        {
            $data->{ 'tags' } .= ",youtube";
        }
        else
        {
            $data->{ 'tags' } .= "youtube";
        }
    }

    #
    #  Return the updated post.
    #
    return ($data);
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
