
=head1 NAME

Chronicle::Plugin::TruncatedBody - Support for Truncating longer blog posts.

=head1 DESCRIPTION

The module allows you to truncate longer blog posts.

To use this you need to add C<__CUT__> within the post body to
the start of its own separate line.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::TruncatedBody;


use strict;
use warnings;

our $VERSION = "5.1.5";


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

If the new entry has a C<__CUT__> on its own line, the text before the
cut is marked as part of the truncated body and a link pointing the
reader to the rest of the article.

The body text is then cleaned by removing C<__CUT__>.

:B<NOTE> If there are multiple __CUT__'s within a file, only the first
correctly placed __CUT__ will be used.  Other __CUTS__ will be ignored
and will remain within the body and or in the truncated body in the case of a
incorrectly placed __CUT__ prior to a correctly placed __CUT__.



=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    #
    #  Get access to the post-data, and configuration-object.
    #
    my $config = $args{ 'config' };
    my $data   = $args{ 'data' };

    #
    #  Get the body of the post, and the link
    #
    my $body = $data->{ 'body' };
    my $link = defined $data->{ 'link' } ? $data->{ 'link' }->as_string : '';

    #
    #  The link needs to be qualified.
    #
    my $top = $config->{ 'top' } || "";
    $link = $top . $link;


    # we are only concerned with first correct cut
    if ( $body =~ /^(.+?)\n^__CUT__/ms )
    {

        # assign the text before the cut to cut and add a link to read more
        $data->{ 'truncatedbody' } = $1 . "\n\n<a href=\"$link\">Read More</a>";

        # remove the cut from the main body
        $data->{ 'body' } =~ s/^(.+?)\n^__CUT__/$1/ms;
    }
    return ($data);
}


# The order is important as we need to run this before any formatting is
# applied to the post
sub _order
{
    1;
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

Stuart Skelton

=cut
