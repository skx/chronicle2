
=head1 NAME

Chronicle::Plugin::DBTweak - Speedup import process

=head1 DESCRIPTION

This plugin is responsible for turning off Database synchronization,
which results in a significantly faster import process.

The downside is that we're at risk of data-lass within the SQLite
database because we're not relying upon the operating system to sync
the database between inserts.

For our use-case this is not a concern.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Plugin::DBTweak;

use strict;
use warnings;



=begin doc

This method is called when the database is opened, regardless of whether
the database was created or already existed.

If you only wish to invoke code when the database is created, to add
new columns or tables for example, you should ues `on_db_create`.

=end doc

=cut

sub on_db_load
{
    my ( $self, %args ) = (@_);

    my $dbh = $args{ 'dbh' };

    $dbh->do("PRAGMA synchronous = OFF");
    $dbh->do("PRAGMA cache_size = 400000");
}


1;
