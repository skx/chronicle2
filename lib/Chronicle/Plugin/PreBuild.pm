
=head1 NAME

Chronicle::Plugin::PreBuild - Execute commands before building the blog

=head1 DESCRIPTION

This module exists to provide compatibility with previous
releases of chronicle, which allowed the user to specify
commands to be executed prior to the blog generation.

If your configuration file defines a command to before
building your blog this module will ensure it is executed.

For example you might write this in your configuration file:

=for example begin

  pre-build = rsync -vazr user@remote::comments/ comments/

=for example end

Multiple commands may be defined, and they will be executed
in the order listed.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::PreBuild;


use strict;
use warnings;


our $VERSION = "5.0.9";


=head2 on_initiate

The C<on_initiate> method is automatically invoked just before any
C<on_generate> methods which might be present.

This method merely looks for defined pre-build commands, and if any
are encountered they are executed via C<system>.

=cut

sub on_initiate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{dbh};
    my $config = $args{config};

    return unless ( $config->{'pre-build'} );

    foreach my $cmd ( @{ $config->{'pre-build'} } )
    {
        $config->{verbose} && print "PreBuild($cmd)\n";

        system($cmd );
    }
}


=head2 _order

We ensure that this plugin is invoked last by setting a priority of 0,
which is lower than the default supported by L<Module::Pluggable::Ordered>.

This method is present such that L<Module::Pluggable::Ordered> can
order our plugins.

=cut

sub _order
{
    return 0;
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
