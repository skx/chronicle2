
=head1 NAME

Chronicle::Plugin::SkipDrafts - Ignore draft posts.

=head1 DESCRIPTION

If your blog-post contains a "C<draft: 1>" header then it will
not be inserted into the blog.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::SkipDrafts;

use strict;
use warnings;


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

Here we look for a C<draft:1> header in the post, if one is found then
the method returns undef which causes it to be excluded from the blog
generation process.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $config = $args{ 'config' };
    my $data   = $args{ 'data' };

    #
    #  We'll return undef here, which will stop the insertion process
    #
    if ( $data->{ 'draft' } )
    {
        $config->{ 'verbose' } &&
          $data->{ 'filename' } &&
          print "Skipping draft: $data->{'filename'} \n";

        ## no critic (ReturnUndef)
        return undef;
        ## use critic
    }

    #
    #  Otherwise return the unmodified data.
    #
    return ($data);
}


1;

