
=head1 NAME

Chronicle::Plugin::Generate::LowerCase - Generate redirection pages

=head1 DESCRIPTION

If Chronicle has been configured to solely generate lower-case posts
then this plugin will setup redirections to those, as appropriate.

For example you might write the post:

=for example begin

   Title: I'm Mixed-Case
   Date: 10th March 2017
   Tags: foo, bar,baz

=for example end

By default this would produce:

=over 8

=item http://example.com/I_m_Mixed_Case.html

=back

Because lower-casing is in effect though instead the file generated
will be:

=over 8

=item http://example.com/i_m_mixed_case.html

=back

This plugin will configure a redirection from the former to the latter.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Generate::LowerCase;


use strict;
use warnings;


our $VERSION = "5.1.6";


=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating redirections if lower-casing
is being enforced.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    #
    #  We're not concerned with anything if lower-casing
    # isn't present
    #
    return unless ( $config->{ 'lower-case' } );


    my $all = $dbh->prepare("SELECT id FROM blog ORDER BY date ASC") or
      die "Failed to find posts";

    my $now = time;

    my @all = ();

    $all->execute() or die "Failed to execute:" . $dbh->errstr();
    my $id;
    $all->bind_columns( undef, \$id );

    #
    # Build up the list of all the post IDs
    #
    # We could build these on-demand, but instead maintain a list
    # such that we can add next_link, next_title, etc, and allow
    # paging through blog-entries.
    #
    while ( $all->fetch() )
    {
        push( @all, $id );
    }



    #
    #  If there is a theme-provided file then use it.
    #
    my $c = Chronicle::load_template("redirect.tmpl");

    #
    #  If not then we're going to use our default, which is
    # contained in the __DATA__ section of this very module.
    #
    if ( !$c )
    {
        my $tmpl = do {local $/; <DATA>};

        #
        #  If there is no template read then something weird has happened
        #
        return unless ( $tmpl && length($tmpl) );

        #
        #  Load the template
        #
        $c = Chronicle::load_template( undef, $tmpl );
    }


    #
    #  At this point we should have one of the two templates loaded,
    # but if not .. we'll just return.
    #
    return unless ($c);



    #
    #  Now we have all the posts we iterate over them in-order.
    #
    for my $index ( 0 .. $#all )
    {
        #
        # The ID of the entry we're processing.
        #
        my $id = $all[$index];

        #
        #  Read the details of the main entry.
        #
        my $entry = Chronicle::getBlog( dbh    => $dbh,
                                        id     => $id,
                                        config => $config
                                      );

        #
        #  Does the entry have a mixed-case title?
        #
        if ( $entry->{ 'link' } =~ /[A-Z]/ )
        {

            #
            #  Ensure we have a full output path - because a plugin might have given us a dated-path.
            #
            my $dir = File::Basename::dirname(
                             $config->{ 'output' } . "/" . $entry->{ 'link' } );
            if ( !-d $dir )
            {
                File::Path::make_path( $dir,
                                       {  verbose => 0,
                                          mode    => oct("755"),
                                       } );
            }

            my $out =
              $config->{ 'output' } . "/" . $entry->{ 'link' }->unescaped;

            $config->{ 'verbose' } &&
              print "Writing redirection to $out for mixed-case post " .
              lc( $entry->{ 'link' } ) . "\n";


            #
            #  Clear the template, and populate it
            #
            $c->clear();
            $c->param( top    => $config->{ 'top' } );
            $c->param( target => lc( $entry->{ 'link' } ) );

            #
            # Write it out
            #
            open( my $handle, ">:encoding(UTF-8)", $out ) or
              die "Failed to open `$out' for writing: $!";
            print $handle $c->output();
            close($handle);


        }
    }

    $all->finish();
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

__DATA__
<!DOCTYPE html>
 <html lang="en">
 <head>
  <title>Blog Post Moved</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="refresh" content="0; url=<!-- tmpl_var name='top' --><!-- tmpl_var name='target' -->">
  <link rel="canonical" href="<!-- tmpl_var name='top' --><!-- tmpl_var name='target' -->">
 </head>
 <body>
  <h1>Post Moved</h1>
  <p>Please find the post here:</p>
  <ul>
   <li><a href="<!-- tmpl_var name='top' --><!-- tmpl_var name='target' -->"><!-- tmpl_var name='top' --><!-- tmpl_var name='target' --></a></li>
  </ul>
 </body>
</html>
