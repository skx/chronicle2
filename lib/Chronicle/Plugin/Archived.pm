#
#  This is a fun plugin.
#
#  It rewrites the output file of each individual post
# so that rather than creating:
#
#   /one_post.html
#
#  We create:
#
#   /2014/09/one_post.html
#
#  You can tweak to your tastes if you want to give posts IDs based
# on the day too.
#
#
package Chronicle::Plugin::Archived;

use Date::Format;
use Date::Parse;


sub modify_entry
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

