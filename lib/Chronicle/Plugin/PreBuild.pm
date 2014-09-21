
=head1 NAME

Chronicle::Plugin::PreBuild - Execute a command pre-build

=head1 DESCRIPTION

This is module exists to provide compatibility with previous
releases, which allowed the user to specify a command to be
executed prior to the blog-generation.

If your configuration file defines a command to execute prior
to building your blog this module will ensure it is executed.

For example:

=for example begin

  pre-build = rsync -vazr user@remote::comments/ comments/

=for example end

B<NOTE> The working directory will not be changed prior to executing the command.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

package Chronicle::Plugin::PreBuild;

use strict;
use warnings;



sub on_initiate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    return unless ( $config->{ 'pre-build' } );

    foreach my $cmd ( @{ $config->{ 'pre-build' } } )
    {
        $config->{ 'verbose' } && print "PreBuild($cmd)\n";

        system($cmd );
    }
}


sub _order
{
    return 0;
}

1;
