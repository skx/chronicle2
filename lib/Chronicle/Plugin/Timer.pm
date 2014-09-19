
=head1 NAME

Chronicle::Plugin::Timer - Record the run-time.

=head1 DESCRIPTION

This module just reports the time taken to generate a blog.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

package Chronicle::Plugin::Timer;

use strict;
use warnings;

our $start;


sub on_initiate
{
    my ( $self, %args ) = (@_);

    my $dbh    = $args{ 'dbh' };
    my $config = $args{ 'config' };

    $start = time;
}

sub on_terminate
{
    my $end  = time;
    my $time = $end - $start;
    print "Blog generated in $time seconds\n";
}

1;
