
=head1 NAME

Chronicle::Plugin::Markdown - Support markdown-formatted input.

=head1 DESCRIPTION

The module allows you to write your input blog-entries in the
Markdown format.

Add the "C<format: markdown>" header to your entries and they
will be automatically converted as part of the import process.

NOTE:  If you enable/disable this plugin you will need to regenerate
your SQLite database, because the conversion happens at import-time.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Markdown;

use strict;
use warnings;


=begin doc

This method will be called whenever a new blog-post is imported to the database.

We look for a format header, and if it is found we'll update the content
if that header has a value of 'textile'.

=end doc

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };
    my $data   = $args{ 'data' };

    if ( $data->{ 'format' } && lc( $data->{ 'format' } ) eq "markdown" )
    {
        my $test = "use Text::Markdown;";
        ## no critic (Eval)
        eval($test);
        ## use critic

        if ($@)
        {
            print <<EOF;
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

