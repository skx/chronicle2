
=head1 NAME

Chronicle::Plugin::Snippets::RecentPosts - Generate recent posts.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the a data-structure to show recent
posts.  Whether you choose to use this in your templates is up to you.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Snippets::RecentPosts;

use strict;
use warnings;


=begin doc

This is a sneaky hook that builds the data-structure, and makes it
globally available.

=end doc

=cut

sub on_initiate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    #
    #  The number of posts include.
    #
    my $count = $config->{ 'entry-count' } || 10;

    my $recent =
      $dbh->prepare("SELECT id FROM blog ORDER BY date DESC LIMIT 0,$count") or
      die "Failed to find recent posts";

    $recent->execute() or die "Failed to execute:" . $dbh->errstr();
    my $id;
    $recent->bind_columns( undef, \$id );


    my $entries = undef;

    while ( $recent->fetch() )
    {
        my $data = Chronicle::getBlog( $dbh, $id );

        push( @$entries,
              {  date  => $data->{ 'date_only' },
                 title => $data->{ 'title' },
                 link  => $data->{ 'link' },
                 tags  => $data->{ 'tags' },
              } );
    }
    $recent->finish();


    #
    #  Now we have the structure.
    #
    $Chronicle::GLOBAL_TEMPLATE_VARS{ "recent_posts" } = $entries if ($entries);
}


=begin doc

This plugin must be called "early".

This means we're called prior to any of the page-generation plugins, such
that any page-templates which make use of the data-structure we've created
are called after that structure is setup.

=end doc

=cut

sub _order
{
    return 0;
}

1;
