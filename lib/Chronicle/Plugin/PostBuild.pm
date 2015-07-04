
=head1 NAME

Chronicle::Plugin::PostBuild - Execute commands after building the blog

=head1 DESCRIPTION

This module exists to provide compatibility with previous
releases of chronicle, which allowed the user to specify
commands to be executed after the blog had been generated.

If your configuration file defines a command to execute after
building your blog this module will ensure it is executed.

For example you might write this in your configuration file:

=for example begin

  post-build = rsync -vazr output/ user@remote:htdocs/

=for example end

Multiple commands may be defined, and they will be executed
in the order listed.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::PostBuild;


use strict;
use warnings;


our $VERSION = "5.1.1";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method merely looks for defined post-build commands, and if any
are encountered they are executed via C<system>.

=cut

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


=head2 _order

We ensure that this plugin is invoked last by setting a priority of 999,
which is greater than the default supported by L<Module::Pluggable::Ordered>.

This method is present such that L<Module::Pluggable::Ordered> can
order our plugins.

=cut

sub _order
{
    return 999;
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
