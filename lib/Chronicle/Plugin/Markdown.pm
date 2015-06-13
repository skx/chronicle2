
=head1 NAME

Chronicle::Plugin::Markdown - Support markdown-formatted input.

=head1 DESCRIPTION

The module allows you to write your input blog-entries in the
Markdown format.

Add the C<format: markdown> header to your entries and they
will be automatically converted as part of the import process.

B<NOTE>  If you enable/disable this plugin you will need to regenerate
your SQLite database, because the conversion happens at import-time.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Markdown;


use strict;
use warnings;


our $VERSION = "5.0.9";


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

If the new entry has a C<format:> header which contains the value C<markdown>
we invoke the L<Text::Markdown> module to perform the HTML conversion.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    #
    #  The post data and input format
    #
    my $data   = $args{data};
    my $format = $data->{format};

    if ( $format && ( $format =~ /^markdown$/i ) )
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

        foreach my $key (qw! truncatedbody body !)
        {
            $data->{ $key } = Text::Markdown::markdown( $data->{ $key } )
              if ( $data->{ $key } );
        }



    }
    return ($data);
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
