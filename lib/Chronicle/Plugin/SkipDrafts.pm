
=head1 NAME

Chronicle::Plugin::SkipDrafts - Ignore posts which are drafts.

=head1 DESCRIPTION

If your blog-post contains a "C<Draft: 1>" header then it will
not be inserted into the blog.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::SkipDrafts;

use strict;
use warnings;

use Date::Format;
use Date::Parse;


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
        $config->{ 'verbose' } && $data->{'filename'} &&
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

