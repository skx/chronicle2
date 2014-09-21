
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

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


package Chronicle::Config::Reader;

use strict;
use warnings;


=begin doc

Constructor.  No arguments required/expected.

=end doc

=cut

sub new
{
    my ($proto) = (@_);
    my $class = ref($proto) || $proto;
    my $self = {};
    bless( $self, $class );
    return $self;
}



=begin doc

Parse a configuration file, and insert any values into the provided
hash-reference.

=end doc

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



=begin doc

Parse a single line.

=end doc

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
