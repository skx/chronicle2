
=head1 NAME

Chronicle::Plugin::Snippets::AllTags - Generate a list of tags.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the a data-structure to show all
previously-used tags.

To use this in your templates add the following:

=for example begin

    <!-- tmpl_if name='all_tags' -->
      <li>
      <!-- tmpl_loop name='all_tags' -->
        <li><a href="/tags/<!-- tmpl_var name='tag' -->"><!-- tmpl_var name='tag' --></a></li>
      <!-- /tmpl_loop name='all_tags' -->
      </ul>
    <!-- /tmpl_if name='all_tags' -->

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


package Chronicle::Plugin::Snippets::AllTags;

use strict;
use warnings;




=begin doc

Generate the global variable 'all_tags' which can be used in the side-bar,
etc.

=end doc

=cut

sub on_initiate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    #
    # Get the tags, and their count.
    #
    my $sql = $dbh->prepare(
        'SELECT DISTINCT(name),COUNT(name) AS runningtotal FROM tags GROUP BY name ORDER BY name'
      ) or
      die "Failed to prepare tag cloud";
    $sql->execute() or die "Failed to execute: " . $dbh->errstr();

    my ( $tag, $count );
    $sql->bind_columns( undef, \$tag, \$count );

    my $tags;

    #
    # Process the results.
    #
    while ( $sql->fetch() )
    {
        my $size = $count * 5 + 5;
        if ( $size > 60 ) {$size = 60;}

        push( @$tags,
              {  tag   => $tag,
                 count => $count,
                 tsize => $size
              } );

    }
    $sql->finish();


    #
    #  Now we have the structure.
    #
    $Chronicle::GLOBAL_TEMPLATE_VARS{ "all_tags" } = $tags if ($tags);
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
