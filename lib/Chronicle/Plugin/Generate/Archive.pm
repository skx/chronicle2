
=head1 NAME

Chronicle::Plugin::Generate::Archive - Generate archive pages.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_terminate> hook which Chronicle provides.

It is responsible for creating the top-level /archive/ pages
which contain a list of previously created posts.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut



package Chronicle::Plugin::Generate::Archive;

use strict;
use warnings;


=begin doc

Output pages for each year/month we've ever seen `output/archive/$year/$mon`.

This is not yet complete and will need more love.

=end doc

=cut

sub on_terminate
{
    my ( $self, $config, $dbh ) = (@_);


    my %mons = ( "01" => 'January',
                 "02" => 'February',
                 "03" => 'March',
                 "04" => 'April',
                 "05" => 'May',
                 "06" => 'June',
                 "07" => 'July',
                 "08" => 'August',
                 "09" => 'September',
                 "10" => 'October',
                 "11" => 'November',
                 "12" => 'December'
               );



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
                     month_name => $mons{ $mon },
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


    $config->{ 'verbose' } &&
      print "Creating : $config->{'output'}/archive/index.html\n";

    my $c = Chronicle::load_template("archive_index.tmpl");
    $c->param( top     => $config->{ 'top' } );
    $c->param( archive => $data );
    open( my $handle, ">", "$config->{'output'}/archive/index.html" ) or
      die "Failed to open";
    print $handle $c->output();
    close($handle);


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
        next if ( -e "$config->{'output'}/archive/$year/$mon" );

        File::Path::make_path( "$config->{'output'}/archive/$year/$mon",
                               {  verbose => 0,
                                  mode    => oct("755"),
                               } );


        my $entries;

        while ( $ids->fetch() )
        {
            push( @$entries, Chronicle::getBlog( $dbh, $id ) );
        }
        $ids->finish();


        $config->{ 'verbose' } &&
          print
          "Creating : $config->{'output'}/archive/$year/$mon/index.html\n";

        my $c = Chronicle::load_template("/archive.tmpl");
        $c->param( top        => $config->{ 'top' } );
        $c->param( entries    => $entries );
        $c->param( month      => $mon, year => $year );
        $c->param( month_name => $mons{ $mon } );
        open( my $handle, ">:encoding(UTF-8)",
              "$config->{'output'}/archive/$year/$mon/index.html" ) or
          die "Failed to open";
        print $handle $c->output();
        close($handle);


    }


}

1;
