
=head1 NAME

Chronicle::Plugin::PostBuild - Execute a command post-build

=head1 DESCRIPTION

This is module exists to provide compatibility with previous
releases, which allowed the user to specify a command to be
executed after the blog had been generated.

If your configuration file defines a command to execute after
building your blog this module will ensure it is executed.

For example:

=for example begin

  post-build = rsync -vazr output/ user@remote:htdocs/

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

package Chronicle::Plugin::PostBuild;

use strict;
use warnings;



sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    return unless ( $config->{ 'post-build' } );

    foreach my $cmd ( @{ $config->{ 'post-build' } } )
    {
        $config->{ 'verbose' } && print "PostBuild($cmd)\n";
        system($cmd );
    }
}


sub _order
{
    return 999;
}

1;
