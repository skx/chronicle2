
=head1 NAME

Chronicle::Plugin::Archived - Generate dated-posts.

=head1 DESCRIPTION

This module is disabled by default, but if it is enabled your generated
blog will contain links to dated posts.

For example by default a blog entry might be generated with a URL such
as C<http://example.com/my_first_post.html>.  With this module enabled
that will change to C<http://example.com/2015/09/my_first_post.html>.

B<NOTE> If you enable or disable this plugin you will need to regenerate
your SQLite database.

See also C<Chronicle::Plugin::InPlacePosts>.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Archived;

use strict;
use warnings;


our $VERSION = "5.1.5";


use Date::Format;
use Date::Parse;

=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

In this method we rewrite the link of the pending post such that it
is prefixed with the year and month - turning the link into a dated
one.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };
    my $data   = $args{ 'data' };

    #
    #  Convert the date of the post to a seconds past epoch.
    #
    my $date = str2time( $data->{ 'date' } );

    #
    #  Now build up a new prefix for the file
    #
    $date = time2str( "%Y/%m/", $date );

    #
    #  And prepend that to the link.
    #
    $data->{ 'link' }->path_prepend($date);

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
