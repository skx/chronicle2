
=head1 NAME

Chronicle::Plugin::InPlacePosts - maintains the input directory structure.

=head1 DESCRIPTION

This plugin is designed to allow blog entries remain in the same
directory structure as the input folder by adding the config
C<entry_inplace>.

The default behaviour of chronicle is to flatten any posts
present in the input folder to the http doc root, however this
plugin sets to replicate the input folder stucture.

=for example begin

input/
    2015/
        June/
            15/
                A_post.post


output/
    2015/
        June/
            15/
                A_post.html

=for example end

See also C<Chronicle::Plugin::Archived>.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::InPlacePosts;

use strict;
use warnings;

our $VERSION = "5.1.2";


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog meta-data,
after performing any massaging required.  

If within the config has C<entry_inplace = 1> the posts link meta-data
is changed to reflect the users intent to retain the posts input location.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $config = $args{ 'config' };
    my $data   = $args{ 'data' };

    if ( $config->{ 'entry_inplace' } )
    {
        $config->{ 'verbose' } &&
          print "Changing Link to stay in place: $data->{'file'}\n";

        my $inplacelink = $data->{ 'file' };

        # strip off the source dir with the first '/'
        # this will be added back later
        my $input = $config->{ 'input' };
        $inplacelink =~ s#$input/?##;

        # strip off the filename and add the title in its place
        $inplacelink =~ s#/?[^/]+$##;

        # if the $inplacelink variable is empty it means the file lives
        # in the root of the input directory, and does not require a '/'
        # to be added between the inplace link and the file name.
        # Conversely if $inplacelink is not empty the file lives within
        # we need to add a '/' between it ans the file name
        $inplacelink .= '/' if ( $inplacelink !~ /^\s*$/ );

        $data->{ 'link' }->path_prepend($inplacelink);
    }

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

Stuart Skelton

=cut
