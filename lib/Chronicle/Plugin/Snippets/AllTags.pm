
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


=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Snippets::AllTags;


use strict;
use warnings;


our $VERSION = "5.0.6";


=head2 on_initiate

The C<on_initiate> method is automatically invoked just before any
C<on_generate> methods which might be present.

This method updates the global variables, which are made available to
all loaded templates, to define a C<all_tags> variable containing the
all the tags which have ever been used within a blog, along with their
use-counts.

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


=head2 _order

This plugin must be called "early".

This means we're called prior to any of the page-generation plugins, such
that any page-templates which make use of the data-structure we've created
are called after that structure is setup.

This method is present such that L<Module::Pluggable::Ordered> can
order our plugins.

=cut

sub _order
{
    return 10;
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
