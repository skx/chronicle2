
=head1 NAME

Chronicle::Plugin::Generate::Pages - Generate each blog page.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating each distinct blog post page.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Generate::Pages;

use strict;
use warnings;




=begin doc

Write out each distinct blog-post.

We avoid overwriting pages which already exist - unless the source has
been modified in the past ten days.

This is designed to ensure that new comments are added to existing pages
without any explicit action being required.

=end doc

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

    my $c = Chronicle::load_template("entry.tmpl");

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

        open( my $handle, ">:utf8",
              $config->{ 'output' } . "/" . $entry->{ 'link' } ) or
          die "Failed to open";
        print $handle $c->output();
        close($handle);

    }

    $all->finish();
}



1;
