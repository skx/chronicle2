
=head1 NAME

Chronicle::Plugin::Generate::Pages - Generate each blog page.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating each distinct blog post page.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Generate::Pages;


use strict;
use warnings;


our $VERSION = "5.1.5";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating each distinct blog-post for
your site, via the theme-template C<entry.tmpl>.

If pages have previously been generated, and exist on-disk already,
then we skip regenerating them unless either:

=over 8

=item The C<--force> flag was used.

=item The post was written within the past ten days, and comments are enabled.

=back

The latter point is designed to ensure that a rebuild will pick up
any recent comments added to your posts without manual attention.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };


    my $all = $dbh->prepare("SELECT id FROM blog ORDER BY date ASC") or
      die "Failed to find posts";

    my $now = time;

    my @all = ();

    $all->execute() or die "Failed to execute:" . $dbh->errstr();
    my $id;
    $all->bind_columns( undef, \$id );

    #
    # Build up the list of all the post IDs
    #
    # We could build these on-demand, but instead maintain a list
    # such that we can add next_link, next_title, etc, and allow
    # paging through blog-entries.
    #
    while ( $all->fetch() )
    {
        push( @all, $id );
    }


    #
    #  Now we have all the posts we iterate over them in-order.
    #
    for my $index ( 0 .. $#all )
    {
        my $id = $all[$index];

        #
        #  The previous blog entry and next blog entry, sequentially
        #
        my $prev_id = undef;
        my $next_id = undef;

        $prev_id = $all[$index - 1] if ( $index > 0 );
        $next_id = $all[$index + 1] if ( $index < $#all );

        #
        #  Read the details of the main entry.
        #
        my $entry = Chronicle::getBlog( dbh    => $dbh,
                                        id     => $id,
                                        config => $config
                                      );

        #
        #  Work out where it will be written to
        #
        my $out = $config->{ 'output' } . "/" . $entry->{ 'link' }->unescaped;
        #
        #  We skip posts that are already present:
        #
        #  * Unless they were posted recently and comments enabled.
        #
        # or
        #
        #  * The --force flag was used.
        #

        my $skip = 0;

        #
        #  So skip it if it exists.
        #
        $skip = 1 if ( -e $out );

        #
        # Unless --force overrides that.
        #
        $skip = 0 if ( $config->{ 'force' } );

        #
        # Finally if comments were enabled and this is recent then
        # we'll also force it to be generated
        #
        $skip = 0
          if ( ( $config->{ 'comments' } ) &&
               ( ( $now - $entry->{ 'posted' } ) <
                 ( 60 * 60 * 24 * $config->{ 'comment-days' } ) ) );


        #
        #  Loop again if we're skipping this post.
        #
        next if ($skip);


        $config->{ 'verbose' } &&
          print "Creating : $out\n";

        my $c = Chronicle::load_template( $entry->{ 'template' } );
        return unless ($c);
        $c->param( top => $config->{ 'top' } );
        $c->param($entry);

        #
        #  If we have a prev/next entry then add their details too.
        #
        if ($prev_id)
        {
            my $prev =
              Chronicle::getBlog( dbh    => $dbh,
                                  id     => $prev_id,
                                  config => $config
                                );
            $c->param( prev_id    => $prev_id,
                       prev_title => $prev->{ 'title' },
                       prev_link  => $prev->{ 'link' } );
        }
        if ($next_id)
        {
            my $next =
              Chronicle::getBlog( dbh    => $dbh,
                                  id     => $next_id,
                                  config => $config
                                );
            $c->param( next_id    => $next_id,
                       next_title => $next->{ 'title' },
                       next_link  => $next->{ 'link' } );
        }

        #
        #  Ensure we have a full output path - because a plugin might have given us a dated-path.
        #
        my $dir = File::Basename::dirname(
                             $config->{ 'output' } . "/" . $entry->{ 'link' } );
        if ( !-d $dir )
        {
            File::Path::make_path( $dir,
                                   {  verbose => 0,
                                      mode    => oct("755"),
                                   } );
        }

        open( my $handle, ">:encoding(UTF-8)", $out ) or
          die "Failed to open `$out' for writing: $!";
        print $handle $c->output();
        close($handle);

    }

    $all->finish();
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
