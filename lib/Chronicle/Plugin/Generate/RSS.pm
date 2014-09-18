package Chronicle::Plugin::Generate::RSS;

use strict;
use warnings;


=begin doc

This is a sneaky hook that outputs the /index.rss file.

=end doc

=cut

sub on_terminate
{
    my ( $self, $config, $dbh ) = (@_);

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
    $c->param( top     => $config->{ 'top' } );
    $c->param( entries => $entries );
    open( my $handle, ">:utf8", "$config->{'output'}/index.rss" ) or
      die "Failed to open";
    print $handle $c->output();
    close($handle);

    if ( $config->{ 'verbose' } )
    {
        print "Wrote " . scalar(@$entries) .
          " items to $config->{'output'}/index.rss\n";
    }

}



1;
