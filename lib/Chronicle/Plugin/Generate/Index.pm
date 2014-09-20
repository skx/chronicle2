
=head1 NAME

Chronicle::Plugin::Generate::Index - Generate the blog-index.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level /index.html file
which is your blogs front-page.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Generate::Index;

use strict;
use warnings;


=begin doc

This is a sneaky hook that outputs the /index.html file.

=end doc

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };


    #
    #  The number of posts to show on the front-page
    #
    my $count = $config->{ 'entry-count' } || 10;

    my $recent =
      $dbh->prepare("SELECT id FROM blog ORDER BY date DESC LIMIT 0,$count") or
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
      print "Creating : $config->{'output'}/index.html\n";

    my $c = Chronicle::load_template("index.tmpl");
    $c->param( top => $config->{ 'top' } );
    $c->param( entries => $entries ) if ($entries);
    open( my $handle, ">:utf8", "$config->{'output'}/index.html" ) or
      die "Failed to open";
    print $handle $c->output();
    close($handle);
}


1;
