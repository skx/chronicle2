
=head1 NAME

Chronicle::Config::Reader - Simple configuration file reader.

=head1 SYNOPSIS

      use strict;
      use warnings;

      use Chronicle::Config::Reader;

      my %config;

      my $helper = Chronicle::Config::Reader->new();

      $helper->parseFile( \%config, "/etc/foo.rc" );

=cut

=head1 DESCRIPTION

This module is contains the code required to read a chronicle configuration
file.  The configuration files it reads are simple files consisting of lines
which are of the form "key=value".

Additional features include:

=over 8

=item Comment Handling

Comments are begun with the C<#> character and continue to the end of the line.

Comments may occur at the start, middle, or end of a line.

=item Environmental variable expansion

Environmental variables are expanded if they are detected.

=item Command-execution and expansion

If backticks are found in configuration values they will be replaced with the output of the specified command.

=back

The following snippet demonstrates these features:

=for example begin

    # The path variable will be set to /bin:/sbin:...
    path = $PATH

    # Our hostname will be set
    hostname = `hostname`

=for example end

=cut


=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Config::Reader;

use strict;
use warnings;



our $VERSION = "5.1.4";


=head2 new

This is the constructor, no arguments are required or expected.

=cut

sub new
{
    my ($proto) = (@_);
    my $class = ref($proto) || $proto;
    my $self = {};
    bless( $self, $class );
    return $self;
}



=head2 parseFile

Parse a configuration file, and insert any values into the provided
hash-reference.

The two parameters required are a hash-reference, which will be updated
with the configuration-values, and the name of the configuration file
to parse.

If the file specified does not exist no action is taken.

Sample usage:

=for example begin

      $cfg->parse( \%config, "/etc/foo/config" );

=for example end

=cut

sub parseFile
{
    my ( $self, $ref, $file ) = (@_);

    #
    #  If it doesn't exist ignore it.
    #
    return if ( !-e $file );

    open my $handle, "<:encoding(utf-8)", $file or
      die "Cannot read file '$file' - $!";

    #
    #  Process each line.
    #
    while ( defined( my $line = <$handle> ) )
    {
        chomp $line;
        if ( $line =~ s/\\$// )
        {
            $line .= <FILE>;
            redo unless eof(FILE);
        }

        $self->parseLine( $ref, $line );
    }

    close($handle);
}



=head2 parseLine

Parse a single line.

This method is called internally, but it is exposed in case it might
be useful to other callers.

The two parameters required are a hash-reference, which will be updated
with the configuration-values, and a line of configuration-file content
which should be parsed.

If the line is missing, or consistes entirely of a comment, this is
not a problem. (e.g. C<"# this is a comment"> will result in no update
to the hash-reference, but also raise no error.)

Sample usage:

=for example begin

     $cfg->parseLine( \%config, 'user = $USER' );

=for example end

=cut

sub parseLine
{
    my ( $self, $ref, $line ) = (@_);

    # Skip lines beginning with comments
    return if ( $line =~ /^([ \t]*)\#/ );

    # Skip blank lines
    return if ( length($line) < 1 );

    # Strip trailing comments.
    if ( $line =~ /(.*)\#(.*)/ )
    {
        $line = $1;
    }

    # Find variable settings
    if ( $line =~ /([^=]+)=([^\n]*)/ )
    {
        my $key = $1;
        my $val = $2;

        # Strip leading and trailing whitespace.
        $key =~ s/^\s+//;
        $key =~ s/\s+$//;
        $val =~ s/^\s+// if ($val);
        $val =~ s/\s+$// if ($val);

        # environment expansion?
        $val =~ s/\$(\w+)/$ENV{$1}/g if ( $val && ( $val =~ /\$/ ) );

        # command expansion?
        if ( $val && ( $val =~ /(.*)`([^`]+)`(.*)/ ) )
        {

            # store
            my $pre  = $1;
            my $cmd  = $2;
            my $post = $3;

            # get output
            my $output = `$cmd`;
            chomp($output);

            # build up replacement.
            $val = $pre . $output . $post;
        }

        if ( $key =~ /^(pre|post)-build$/ )
        {
            push( @{ $ref->{ $key } }, $val );
        }
        else
        {

            #
            # The general case is store the value in the key.
            #
            $ref->{ $key } = $val;
        }
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
