
=head1 NAME

Chronicle::Plugin::Filter - Filter individual blog entries.

=head1 DESCRIPTION

This plugin is designed to allow blog entries to be filtered via
external commands.

This is achieved by opening the specified command and using it as
a filter for the entry prior to the insertion into the database.

As an example the following blog-post would be 100% upper-cased:

=for example begin

    Title: My Title
    Date: 10th March 2015
    Filter: tr a-z A-Z

    <p>This is a line of text.</p>

=for example end

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Filter;


use strict;
use warnings;


our $VERSION = "5.1.1";


use IPC::Open2;
use Symbol;


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

This plugin will look for a series of headers in the blog-post:

=over 8

=item pre-filter

This will be called first.

=item filter

This will be called in the middle.

=item post-filter

This will be called last.

=back

Any such header will be assumed to contain a command that the blog-post
should be piped through.  The post itself will be replaced with C<STDOUT>
from that command.

Because only single headers are examined there can be no more than three
filters per-post.  This constraint exists for compability purposes.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $conf = $args{ 'config' };
    my $data = $args{ 'data' };

    #
    #  The filters we run.
    #
    my @filters;

    #
    #  Look for the following keys in our entry
    #
    foreach my $filter (qw! pre-filter filter post-filter !)
    {
        push( @filters, $data->{ $filter } ) if ( $data->{ $filter } );
    }

    #
    #  No filters defined?  Then return the unmodified post.
    #
    return ($data) unless ( scalar @filters );


    foreach my $filter (@filters)
    {

        #
        #  Get the post body
        #
        my $body = $data->{ 'body' };

        #
        #  Report what we're doing.
        #
        print "Filtering $data->{'file'} via $filter\n"
          if ( $conf->{ 'verbose' } );


        #
        #  Apply the filter.
        #
        my $WTR = gensym();
        my $RDR = gensym();
        my $pid = open2( $RDR, $WTR, $filter );
        print $WTR $body;
        close($WTR);

        #
        #  Get the output
        #
        my $result = "";
        while (<$RDR>)
        {
            $result .= $_;
        }
        waitpid $pid, 0;

        #
        #  Store the updated body.
        #
        $data->{ 'body' } = $result;
    }

    #
    #  Return the updated post.
    #
    return ($data);
}


=head2 _order

We want this plugin to be called I<after> the other plugins which
filter new entries.

This method is present such that L<Module::Pluggable::Ordered> can
order our plugins.

=cut

sub _order
{
    return 200;
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
