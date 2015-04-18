
=head1 NAME

Chronicle::Plugin::Snippets::RecentPosts - Generate recent posts.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the a data-structure to show recent
posts.  The number of posts defaults to ten, but can be changed if
you're using a configuration file, via:

=for example begin

   recent-post-count = 20

=for example end

To use this in your theme add the following:

=for example begin

     <!-- tmpl_if name='recent_posts' -->
     <h3>Recent Posts</h3>
     <ul>
       <!-- tmpl_loop name='recent_posts' -->
       <li><b><!-- tmpl_var name='date' --></b>
       <ul>
          <li><a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='link' -->"><!-- tmpl_var name='title' --></a></li>
       </ul></li>
       <!-- /tmpl_loop -->
     </ul>
     <!-- /tmpl_if name='recent_posts' -->

=for example end

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Snippets::RecentPosts;


use strict;
use warnings;


use Date::Format;
use Date::Parse;



our $VERSION = "5.0.8";


=head2 on_initiate

The C<on_initiate> method is automatically invoked just before any
C<on_generate> methods which might be present.

This method updates the global variables, which are made available to
all loaded templates, to define a C<recent_posts> variable containing
references to the most recent posts.

The number of tags included in that list will default to 10, but can
be changed via the C<recent-post-count> setting in the configuration file.

=cut

sub on_initiate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    #
    #  The number of posts to include.
    #
    my $count = $config->{ 'recent-post-count' } || 10;

    my $recent =
      $dbh->prepare("SELECT id FROM blog ORDER BY date DESC LIMIT 0,$count") or
      die "Failed to find recent posts";

    $recent->execute() or die "Failed to execute:" . $dbh->errstr();
    my $id;
    $recent->bind_columns( undef, \$id );


    my $entries = undef;

    while ( $recent->fetch() )
    {
        my $data = Chronicle::getBlog( dbh    => $dbh,
                                       id     => $id,
                                       config => $config
                                     );

        my $x = $data->{ 'posted' };
        my $date = time2str( "%e %B %Y", $x );

        push( @$entries,
              {  date  => $date,
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
