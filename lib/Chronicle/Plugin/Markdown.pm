package Chronicle::Plugin::Markdown;



sub modify_entry
{
    my ( $self, $data ) = (@_);

    if ( $data->{ 'format' } && lc( $data->{ 'format' } ) eq "markdown" )
    {
        my $test = "use Text::Markdown;";
        ## no critic (Eval)
        eval($test);
        ## use critic

        if ($@)
        {
            print <<EOF;
The file $filename has been written in Markdown.

The perl module Text::Markdown couldn't be loaded.

If you're on a Debian GNU/Linux system you can fix this via:

   apt-get install libtext-markdown-perl
EOF
            exit(1);
        }

        $data->{ 'body' } = Text::Markdown::markdown( $data->{ 'body' } );

    }
    return ($data);
}


1;

