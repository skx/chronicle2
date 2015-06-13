
=head1 NAME

Chronicle::Plugin::DBTweak - Speedup the import process

=head1 DESCRIPTION

This plugin is responsible for turning off database synchronization,
which results in a significantly faster import process.

The downside is that we're at risk of data-lass within the SQLite
database because we're not relying upon the operating system to sync
the database between inserts.

For our use-case this is not a concern.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::DBTweak;

use strict;
use warnings;


our $VERSION = "5.0.9";


=head2 on_db_load

This method is called when the database is opened, regardless of whether
the database was created or already existed.

Here we set the pragmas to speedup the insertion process of new entries.

=cut

sub on_db_load
{
    my ( $self, %args ) = (@_);

    my $dbh = $args{dbh};

    $dbh->do("PRAGMA synchronous = OFF");
    $dbh->do("PRAGMA cache_size = 400000");
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
