
=head1 NAME

Chronicle::Plugin::Snippets::RecentTags - Generate a list of recent tags.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the a data-structure containing
recently used tags.

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

=head1 METHODS

Now follows documentation on the available methods.

=cut


package Chronicle::Plugin::Snippets::RecentTags;


use strict;
use warnings;


our $VERSION = "5.0.7";


=head2 on_initiate

The C<on_initiate> method is automatically invoked just before any
C<on_generate> methods which might be present.

This method updates the global variables, which are made available to
all loaded templates, to define a C<recent_tags> variable containing the
recently used tag-names.

The number of tags included in that list will default to 10, but can
be changed via the C<recent-tag-count> setting in the configuration file.

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
