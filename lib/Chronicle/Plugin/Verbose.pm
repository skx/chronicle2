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
