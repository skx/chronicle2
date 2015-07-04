
=head1 NAME

Chronicle::Plugin::Generate::Index - Generate the blog-index.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level /index.html file
which is your blogs front-page.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut


package Chronicle::Plugin::Generate::Index;


use strict;
use warnings;


our $VERSION = "5.1.1";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating the front-page of your
blog site, via the theme-template C<index.tmpl>.

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
        push( @$entries,
              Chronicle::getBlog( dbh    => $dbh,
                                  id     => $id,
                                  config => $config
                                ) );
    }
    $recent->finish();


    #
    #  The index-file to generate
    #
    my $index = $config->{ 'index_filename' } || "index.html";

    $config->{ 'verbose' } &&
      print "Creating : $config->{'output'}/$index\n";

    my $c = Chronicle::load_template("index.tmpl");
    return unless ($c);

    $c->param( top => $config->{ 'top' } );
    $c->param( entries => $entries ) if ($entries);
    open( my $handle, ">:encoding(UTF-8)", "$config->{'output'}/$index" ) or
      die "Failed to open";
    print $handle $c->output();
    close($handle);
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
