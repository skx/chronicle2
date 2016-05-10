
=head1 NAME

Chronicle::Utils - some utility functions needed here and there

=head1 DESCRIPTION

So far, this only contains the date/time localization function to avoid too
much ugly cross-namespace calling.

=head1 FUNCTIONS

=head2 format_datetime

Format a date or time value to a string. Uses a config setting passed in $config_var
or a default format in $date_fmt to generate both an English and a localized version.
An empty list is returned if the format string doesn't contain a % character.

=cut

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version,
or

b) the Perl "Artistic License".

=cut

=head1 AUTHOR

Matthias Bethke

=cut


package Chronicle::Utils;

use strict;
use warnings;

use Encode qw/ decode /;
use Date::Format;
use Date::Language;
use parent 'Exporter';

our @EXPORT_OK = qw/ format_datetime /;


my $date_loc = Date::Language->new( $ENV{ 'MONTHS' } // "English" );

sub format_datetime
{
    my ( $config, $config_var, $format, $time ) = @_;

    # If the config overrides the default $date_fmt, use it
    $format = $config->{ $config_var } if $config and $config->{ $config_var };

    return unless $format =~ /%/;

    return
      time2str( $format, $time ),
      decode( 'ISO-8859-1', $date_loc->time2str( $format, $time ) );
}

1;
