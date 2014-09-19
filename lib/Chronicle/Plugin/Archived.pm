
=head1 NAME

Chronicle::Plugin::Archived - Generate dated-posts.

=head1 DESCRIPTION

This module is disabled by default.

The module allows you to created dated blog-posts.  By default
posts you make will be located at:

=over 8

=item http://example.com/this_is_my_first_entry.html

=item http://example.com/this_is_my_second_post.html

=back

With this plugin enabled your posts will instead be located
in named sub-directories based upon the date, for example:

=over 8

=item http://example.com/2014/09/this_is_my_first_post.html

=item http://example.com/2014/09/this_is_my_second_post.html

=back

NOTE:  If you enable/disable this plugin you will need to regenerate
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
    my ( $self, $data ) = (@_);

    #
    #  Disabled
    #
    return ($data);


    #
    #  Convert the date of the post to a seconds past epoch.
    #
    my $date = str2time( $data->{ 'date' } );

    #
    #  Now build up a new prefix for the file
    #
    $date = time2str( "%Y/%m/", $date );

    #
    #  And prepend that.
    #
    $data->{ 'link' } = $date . $data->{ 'link' };
    return ($data);
}


1;

