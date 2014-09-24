
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


our $VERSION = "5.0.6";


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

=item The post was written within the past ten days.

=back

The latter point is designed to ensure that a rebuild will pick up
any recent comments added to your posts without manual attention.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };


    my $all = $dbh->prepare("SELECT id FROM blog") or
      die "Failed to find posts";

    my $now = time;

    $all->execute() or die "Failed to execute:" . $dbh->errstr();
    my $id;
    $all->bind_columns( undef, \$id );

    while ( $all->fetch() )
    {

        #
        #  Read the details of this single entry.
        #
        my $entry = Chronicle::getBlog( $dbh, $id );

        #
        #  We skip posts that are already present - UNLESS they are posted
        # within the past ten days.
        #
        #  This means that we automatically include new comments when
        # rebuilding a recent post.
        #
        #  Of course if you run "make clean" then you'll rebuild all
        # pages, regardless of the age.
        #
        next
          if ( ( -e $config->{ 'output' } . "/" . $entry->{ 'link' } ) &&
               ( ( $now - $entry->{ 'posted' } ) >
                 ( 60 * 60 * 24 * $config->{ 'comment-days' } ) ) &&
               ( !$config->{ 'force' } ) );


        $config->{ 'verbose' } &&
          print "Creating : $config->{'output'}/$entry->{'link'}\n";


        my $c = Chronicle::load_template("entry.tmpl");
        $c->param( top => $config->{ 'top' } );
        $c->param($entry);

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

        open( my $handle, ">:encoding(UTF-8)",
              $config->{ 'output' } . "/" . $entry->{ 'link' } ) or
          die "Failed to open";
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
