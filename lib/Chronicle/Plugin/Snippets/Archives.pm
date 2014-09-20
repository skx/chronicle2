
=head1 NAME

Chronicle::Plugin::Snippets::Archives - Generate archives.

=head1 DESCRIPTION

This module will be invoked automatically when your site is built
via the C<on_generate> hook which Chronicle provides.

It is responsible for creating the a data-structure to show archived
posts which is a nested loop of:

=for example begin

    year1/
      month1 - count
      month2 - count
      ..
    year2/
      month1 - count
      month2 - count
      ..

=for example end

Whether you choose to use this in your templates is up to you.

Like most of these global-data the output will look reasonable, and be fast,
for a small number of posts, but quickly become slow and crowded with a large
history.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::Snippets::Archives;

use strict;
use warnings;


=begin doc

This is a sneaky hook that builds the data-structure, and makes it
globally available.

=end doc

=cut

sub on_initiate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

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
    #  The results we'll populate
    #
    my $data;


    #
    #  For each year
    #
    foreach my $year ( $self->_years($dbh) )
    {
        my $tmp;

        foreach my $mon ( $self->_months_in_year( $dbh, $year ) )
        {
            #
            #  We have a year and a month.
            #
            my $sql = $dbh->prepare(
        "SELECT count(id) FROM blog WHERE ( strftime('%Y', date, 'unixepoch')=? AND strftime('%m', date, 'unixepoch') =? )"
                               ) or
                                 die "Failed to prepare query";

            $sql->execute($year, $mon);
            my $count = $sql->fetchrow_array();

            push( @$tmp, { month => $mon,
                          month_name => $mons{$mon},
                          count => $count } );


            $sql->finish();
        }

        push( @$data , { year => $year,
                         months => $tmp } );

    }

    #
    #  Now we have the structure.
    #
    $Chronicle::GLOBAL_TEMPLATE_VARS{ "archived_posts" } = $data if ($data);

}


=begin doc

Find distinct years which have had posts in them.

=end doc

=cut

sub _years
{
    my( $self, $dbh ) = ( @_ );

    my @results;

    #
    #  Find each year.
    #
    my $years = $dbh->prepare(
        "SELECT DISTINCT(strftime( '%Y', date, 'unixepoch')) FROM blog ORDER BY strftime( '%s', date, 'unixepoch' ) DESC"
      ) or
      die "Failed to prepare query";

    $years->execute() or die "Failed to execute:" . $dbh->errstr();
    my $year;
    $years->bind_columns( undef, \$year );


    while ( $years->fetch() )
    {
        push( @results, $year );
    }

    $years->finish();

    return( @results );
}



=begin doc

Find distinct months which have had posts in them, from the given year.

=end doc

=cut

sub _months_in_year
{
    my( $self, $dbh, $year ) = ( @_ );

    my @results;

    #
    #  Find each year.
    #
    my $s = $dbh->prepare(
        "SELECT DISTINCT(strftime( '%m', date, 'unixepoch')) FROM blog WHERE (strftime('%Y',date,'unixepoch') = ?) ORDER BY strftime( '%s', date, 'unixepoch' ) DESC"
      ) or
      die "Failed to prepare query";

    $s->execute($year) or die "Failed to execute:" . $dbh->errstr();
    my $mon;
    $s->bind_columns( undef, \$mon );

    while ( $s->fetch() )
    {
        push( @results, $mon );
    }

    $s->finish();

    return( @results );
}



=begin doc

This plugin must be called "early".

This means we're called prior to any of the page-generation plugins, such
that any page-templates which make use of the data-structure we've created
are called after that structure is setup.

=end doc

=cut

sub _order
{
    return 0;
}

1;
