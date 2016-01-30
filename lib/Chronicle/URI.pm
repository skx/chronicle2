package Chronicle::URI;
use strict;
use warnings;
use URI;
use Unicode::Normalize 'normalize';

use parent 'URI';

our $NORMALFORM = 'C';

=head1 NAME

Chronicle::URI - A URI subclass that simplifies handling of HTTP URIs

=head1 DESCRIPTION

It is advantageous to handle URIs as objects for easier Unicode handling,
canonicalization etc.

We ony need HTTP URIs here so we can save some boilerplate by subclassing URI,
but some extra methods for unescaping and prepending/appending also come in
handy.

This class will convert any string arguments passed to it to Unicode NFC form

=head1 METHODS

=head2 new

The constructor takes only a single argument that will be assumed to be an http
URI, or in our case usually a path fragment thereof.

=cut

sub new {
    my ($class, $path) = @_;
    my $self = $class->SUPER::new( normalize($NORMALFORM, $path), 'http' );
    return bless $self, $class;
}

=head2 unescaped

Return the URI or framgemt completely unescaped. That is, the result of
URI::as_iri with additionally all the ASCII characters unescaped. This method
is supposed to generate a filename from an URI.

=cut

sub unescaped {
    my ($self) = @_;
    my $iri = $self->as_iri;
    # Unescape all the ASCII left escaped by as_iri();
    $iri =~ s/%([[:xdigit:]]{2})/chr(hex $1)/eg;
    return $iri;
}


=head2 path_append

Append its string argument to the path part of the URI.

=cut

sub path_append {
    my ($self, $s) = @_;
    return $self->path( $self->path . normalize($NORMALFORM, $s) ); 
}

=head2 path_prepend

Prepend its string argument to the path part of the URI.

=cut

sub path_prepend {
    my ($self, $s) = @_;
    return $self->path( normalize($NORMALFORM, $s) . $self->path ); 
}

=head2 i_use_hfs

This is a class method that must be called prior to creating any objects that
you want to render in a way that will be compatible with serving them from an
HFS+ file system. HFS+ converts non-ASCII characters in file names to Unicode
NFD form fo URIs have to be composed differently or the corresponding files
won't be found later.

=cut

sub i_use_hfs {
    our $NORMALFORM = 'D';
}

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version,
or

b) the Perl "Artistic License".

=head1 AUTHOR

Matthias Bethke <matthias@towiski.de>

=cut

1;

