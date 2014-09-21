
=head1 NAME

Chronicle::Plugin::Snippets::Tags - Generate tags list.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the a data-structure to show all tags.

To use this plugin add the following to your theme:

=for example begin

   <!-- tmpl_if name='recent_tags' -->
   <h3>Recent Tags</h3>
   <ul>
   <!-- tmpl_loop name='recent_tags' -->
       <li><a href="/tags/<!-- tmpl_var name='tag' -->"><!-- tmpl_var name='tag' --></a></li>
   <!-- /tmpl_loop -->
   </ul>
   <!-- /tmpl_if name='recent_tags' -->

=for example end

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Snippets::RecentTags;

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
    #  The number of tags to include.
    #
    my $count = $config->{ 'recent-tag-count' } || 10;

    my $recent = $dbh->prepare(
        "SELECT a.name FROM tags AS a JOIN blog AS b WHERE ( b.id = a.blog_id  ) ORDER BY b.date DESC LIMIT $count"
      ) or
      die "Failed to find recent tags: " . $dbh->errstr();

    $recent->execute() or die "Failed to execute:" . $dbh->errstr();
    my $tag;
    $recent->bind_columns( undef, \$tag );


    my $entries = undef;

    while ( $recent->fetch() )
    {
        push( @$entries, { tag => $tag } );
    }
    $recent->finish();


    #
    #  Now we have the structure.
    #
    $Chronicle::GLOBAL_TEMPLATE_VARS{ "recent_tags" } = $entries if ($entries);
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
    return 10;
}

1;
