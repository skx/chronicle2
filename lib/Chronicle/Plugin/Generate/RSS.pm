
=head1 NAME

Chronicle::Plugin::Generate::RSS - Generate RSS output.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level /index.rss file
which is your blogs main RSS feed.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut



package Chronicle::Plugin::Generate::RSS;

use strict;
use warnings;


=begin doc

This is a sneaky hook that outputs the /index.rss file.

=end doc

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
    $c->param( top => $config->{ 'top' } );
    $c->param( entries => $entries ) if ($entries);
    open( my $handle, ">:utf8", "$config->{'output'}/index.rss" ) or
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
