
=head1 NAME

Chronicle::Plugin::PostSpooler - Autopost entries in the future.

=head1 DESCRIPTION

This plugin is designed to allow new posts to be scheduled automatically.

Rather than writing a post with a C<date:> header you should instead
write a post with a C<publish:> header.  When such a post is found it
will be added to the blog only if the publish-date is in the past.

This allows you to write a post such as the following, confident it
will not be included until the target date is reached:

=for example begin

   Publish: 10th March 2076
   Subject: I'm a 100 years old
   Tags: life, birthday, fiction

   <p>Hello, I am old.</p>

=for example end

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::PostSpooler;


use strict;
use warnings;


our $VERSION = "5.0.5";


use Date::Format;
use Date::Parse;


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

If the post we're being invoked upon does not contain a C<publish>
header then this plugin will do nothing.

If there is such a header the post will be ignored unless that header
is in the past - if the post refers to a future time it will be skipped.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $config = $args{ 'config' };
    my $data   = $args{ 'data' };

    #
    #  If there is no Publish header then return immediately.
    #
    return $data unless ( $data->{ 'publish' } );

    #
    #  Now we need to see if the post is in the future or not.
    #
    #  Parse the publish-date into seconds and get the current time.
    #
    my $seconds = str2time( $data->{ 'publish' } );
    my $current = time();

    #
    #  Has this date occurred?  If so publish.
    #
    if ( $seconds <= $current )
    {
        $data->{ 'date' } = $data->{ 'publish' };
        delete( $data->{ 'publish' } );
        return ($data);
    }
    else
    {

        #
        # The post will be published in the future,
        # skip it for now.
        #
        return undef;
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
