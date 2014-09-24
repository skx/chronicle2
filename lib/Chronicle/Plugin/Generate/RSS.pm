
=head1 NAME

Chronicle::Plugin::Generate::RSS - Generate RSS output.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level /index.rss file
which is your blogs main RSS feed.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut


package Chronicle::Plugin::Generate::RSS;

use strict;
use warnings;



=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating the RSS-feed of your
blog site, via the theme-template C<index.rxx>.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    my $recent = $dbh->prepare(
        "SELECT id FROM blog ORDER BY date DESC LIMIT 0,$config->{'rss-count'}")
      or
      die "Failed to find recent posts";

    $recent->execute() or die "Failed to execute:" . $dbh->errstr();
    my $id;
    $recent->bind_columns( undef, \$id );


    my $entries;

    while ( $recent->fetch() )
    {
        push( @$entries, Chronicle::getBlog( $dbh, $id ) );
    }
    $recent->finish();


    $config->{ 'verbose' } &&
      print "Creating : $config->{'output'}/index.rss\n";

    my $c = Chronicle::load_template("index.rss");
    return unless ($c);

    $c->param( top => $config->{ 'top' } );
    $c->param( entries => $entries ) if ($entries);
    open( my $handle, ">:encoding(UTF-8)", "$config->{'output'}/index.rss" ) or
      die "Failed to open";
    print $handle $c->output();
    close($handle);

    if ( $config->{ 'verbose' } && $entries )
    {
        print "Wrote " . scalar(@$entries) .
          " items to $config->{'output'}/index.rss\n";
    }

}



1;
