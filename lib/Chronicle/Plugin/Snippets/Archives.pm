
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


package Chronicle::Plugin::Snippets::Archives;


use strict;
use warnings;


our $VERSION = "5.0.9";


=head2 on_initiate

The C<on_initiate> method is automatically invoked just before any
C<on_generate> methods which might be present.

This method updates the global variables, which are made available to
all loaded templates, to define a C<archived_posts> variable containing
a nested loop of all the posts made ever.

The outer-loop contains the years that have posts, and for each distinct
year there is a nested loop containing references to the posts in each
month of that year.


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

            $sql->execute( $year, $mon );
            my $count = $sql->fetchrow_array();

            push( @$tmp,
                  {  month      => $mon,
                     month_name => $mons{ $mon },
                     count      => $count
                  } );


            $sql->finish();
        }

        push( @$data,
              {  year   => $year,
                 months => $tmp
              } );

    }

    #
    #  Now we have the structure.
    #
    $Chronicle::GLOBAL_TEMPLATE_VARS{ "archived_posts" } = $data if ($data);

}


=head2 _years

Find distinct years which have had posts in them.

=cut

sub _years
{
    my ( $self, $dbh ) = (@_);

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

    return (@results);
}



=head2 _months_in_year

Find distinct months which have had posts in them, from the given year.

=cut

sub _months_in_year
{
    my ( $self, $dbh, $year ) = (@_);

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

    return (@results);
}


=head2 _order

This plugin must be called "early".

This means we're called prior to any of the page-generation plugins, such
that any page-templates which make use of the data-structure we've created
are called after that structure is setup.

This method is present such that L<Module::Pluggable::Ordered> can
order our plugins.

=cut

sub _order
{
    return 10;
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
