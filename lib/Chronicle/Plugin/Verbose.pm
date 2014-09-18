
=head1 NAME

Chronicle::Plugin::Verbose - Increase verbosity.

=head1 DESCRIPTION

This module is disabled by default.

This is a simple plugin which is designed to demonstrate
how you can alter the configuration settings that Chronicle
uses - This merely increases/sets the verbosity of the main
process.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Verbose;

sub on_initiate
{
    my ( $self, $config, $dbh ) = (@_);

    #
    #  Disabled.
    #
    return;


    #
    #  This is how you'd update the global config
    #
    $config->{ 'verbose' } = 1;
}


1;
