
=head1 NAME

Chronicle::Plugin::Generate::Archive - Generate archive pages.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the top-level /archive/ pages
which contain a list of previously created posts.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut


package Chronicle::Plugin::Generate::Archive;


use strict;
use warnings;


our $VERSION = "5.1.3";


use Date::Language;

=head2 on_generate

The C<on_generate> method is automatically invoked to generate output
pages.  This particular plugin method is invoked I<after> any
C<on_initiate> methods which might be present.

This method is responsible for generating the archive-output, which
includes two sets of pages:

=over 8

=item C</archive/index.html>

This is created using the C<archive_index.tmpl> theme-template, and contains
a list of all the year/month pairs which have blog-posts present for them.

=item C</archive/$year/$mon/index.html>

This is created for each distinct year/month pair, from the theme-template
C<archive.tmpl>

=back

If either template is missing then this plugin will skip that part of
the generation.

=cut

sub on_generate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    #
    #  Get our language
    #
    my $language = $ENV{ 'MONTHS' } || "English";

    #
    #  Now populate @MONTHS with the month names of that language.
    #
    my $fmt    = Date::Language->new($language);
    my $fmtref = ref($fmt);

    my $names_var = sprintf( '%s::MoY', $fmtref );
    my @MONTHS;

    {
        ## no critic (ProhibitNoStrict)
        no strict 'refs';
        @MONTHS = @{ $names_var };
        use strict 'refs';
        ## use critic
    }


    #
    #  Date-record
    #
    my %hash;
    my %index;

    my $all = $dbh->prepare(
        "SELECT strftime( '%m %Y', date, 'unixepoch') FROM blog ORDER BY strftime( '%s', date, 'unixepoch' ) ASC"
      ) or
      die "Failed to prepare";


    $all->execute() or die "Failed to execute:" . $dbh->errstr();
    my $dt;
    $all->bind_columns( undef, \$dt );

    while ( $all->fetch() )
    {
        if ( $dt =~ /([0-9]+) ([0-9]+)/ )
        {
            $hash{ $dt } += 1;

            $index{ $2 }{ $1 } += 1;
        }
    }
    $all->finish();

    #
    #  Ouptut the index
    #
    my $data;
    foreach my $year ( reverse sort keys %index )
    {
        my $mons = $index{ $year };

        foreach my $mon ( reverse sort keys %$mons )
        {
            push( @$data,
                  {  year       => $year,
                     month      => $mon,
                     month_name => $MONTHS[$mon - 1],
                     count      => $index{ $year }{ $mon } } );
        }
    }


    if ( !-d "$config->{'output'}/archive/" )
    {
        File::Path::make_path( "$config->{'output'}/archive/",
                               {  verbose => 0,
                                  mode    => oct("755"),
                               } );
    }

    #
    #  The index file to generate
    #
    my $index = $config->{ 'index_filename' } || "index.html";

    my $c = Chronicle::load_template("archive_index.tmpl");
    if ($c)
    {
        $config->{ 'verbose' } &&
          print "Creating : $config->{'output'}/archive/$index\n";
        $c->param( top => $config->{ 'top' } );
        $c->param( archive => $data ) if ($data);
        open( my $handle, ">:encoding(UTF-8)",
              "$config->{'output'}/archive/$index" ) or
          die "Failed to open";
        print $handle $c->output();
        close($handle);
    }



    #
    #  Foreach year/mon pair
    #
    foreach my $ym ( keys %hash )
    {
        my $mon  = "";
        my $year = "";
        if ( $ym =~ /^([0-9]+) ([0-9]+)$/ )
        {
            $mon  = $1;
            $year = $2;
        }
        my $ids = $dbh->prepare(
            "SELECT id FROM blog WHERE strftime( '%m %Y', date, 'unixepoch') = ? ORDER BY date DESC"
          ) or
          die "Failed to prepare";

        $ids->execute($ym) or die "Failed to execute:" . $dbh->errstr();

        my $id;
        $ids->bind_columns( undef, \$id );

        # skip if it exists.
        next
          if ( ( -e "$config->{'output'}/archive/$year/$mon" ) &&
               ( !$config->{ 'force' } ) );

        File::Path::make_path( "$config->{'output'}/archive/$year/$mon",
                               {  verbose => 0,
                                  mode    => oct("755"),
                               } );


        my $entries;

        while ( $ids->fetch() )
        {
            push( @$entries,
                  Chronicle::getBlog( dbh    => $dbh,
                                      id     => $id,
                                      config => $config
                                    ) );
        }
        $ids->finish();


        $config->{ 'verbose' } &&
          print "Creating : $config->{'output'}/archive/$year/$mon/$index\n";


        $c = Chronicle::load_template("/archive.tmpl");
        return if ( !$c );

        $c->param( top        => $config->{ 'top' } );
        $c->param( entries    => $entries );
        $c->param( month      => $mon, year => $year );
        $c->param( month_name => $MONTHS[$mon - 1] );
        open( my $handle, ">:encoding(UTF-8)",
              "$config->{'output'}/archive/$year/$mon/$index" ) or
          die "Failed to open";
        print $handle $c->output();
        close($handle);


    }

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
