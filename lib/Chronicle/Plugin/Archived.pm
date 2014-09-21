
=head1 NAME

Chronicle::Plugin::Archived - Generate dated-posts.

=head1 DESCRIPTION

This module is disabled by default, but if it is enabled your generated
blog will contain links to dated posts.

For example by default a blog entry might be generated with a URL such
as C<http://example.com/my_first_post.html>.  With this module enabled
that will change to C<http://example.com/2014/09/my_first_post.html>.

B<NOTE> If you enable or disable this plugin you will need to regenerate
your SQLite database.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Archived;

use strict;
use warnings;

use Date::Format;
use Date::Parse;


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
    $data->{ 'link' } = $date . $data->{ 'link' };

    return ($data);
}


1;

