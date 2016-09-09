package Chronicle::Template;

use strict;
use warnings;
use Path::Class;
use POSIX qw/ :locale_h strftime /;
use Encode;
use Carp;

=head1 NAME

Chronicle::Template - Base class for Chronicle's template abstractions

=head1 DESCRIPTION

This class should be used as a base class for Template plugins and provides a
few utility methods for writing those. For users of the template plugins, it
also provides the factory method L<create> that takes care of loading and
instantiating the required subclass.

=head1 METHODS

=head2 new

The constructor takes a file name as a mandatory agument and a number of options as key-value pairs.
The following options are currently defined:

=over 2

=item C<theme_dir> Where to look for themes

=item C<theme> Name of the theme to use

=back

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



package Chronicle::Template;

use strict;
use warnings;

use Path::Class;
use Carp;


=head2 new

Constructor.

=cut

sub new
{
    my ( $class, %options ) = @_;
    exists $options{ tmpl_string } or
      exists $options{ tmpl_file } or
      confess(
        "BUG: neither tmpl_string nor tmpl_file set in template instantiation");

    return
      bless { theme_dir => $options{ theme_dir } // '',
              theme     => $options{ theme }     // '',
            }, $class;
}

=head2 create

This factory method takes the template text or file name as the only mandatory
parameter and returns an instance of a L<Chronicle::Template> subclass. A
number of optional parameters may follow as key-value pairs. All of these
options are passed to the subclass' constructor except for C<type>. C<type>
specifies the desired subclass; default is "HTMLTemplate" for compatibility
with the old hardcoded templates.

The following values are currently valid for C<type>:

=over 2

=item HTMLTemplate

=item Xslate

=back

=cut

sub create
{
    my ( $class, %options ) = @_;

    #  Ensure we have a theme.
    $options{ 'theme' } or die "You must specify a theme with --theme";

    #  Ensure the theme directory exists.
    -d $options{ theme_dir } or
      die
      "The theme directory specified with 'theme-dir' ($options{ theme_dir }) doesn't exist";

    # If a template file was specified, remove the extension if present
    exists $options{ tmpl_file } and
      defined $options{ tmpl_file } and
      $options{ tmpl_file } =~ s/\..+$//;

    # Unless the caller has specified a template type, assume "HTMLTemplate"
    my $type = delete $options{ type } // "HTMLTemplate";
    require "Chronicle/Template/$type.pm";
    return "Chronicle::Template::$type"->new(%options);
}


=head2 param

Add a parameter that can be used in template expansion later. Takes a key and a
value to add.

=cut

sub param
{
    my ( $self, $key, $val ) = @_;
    if ( ref $key eq 'HASH' )
    {
        $self->{ params }{ $_ } = $key->{ $_ } for keys %$key;
    }
    else
    {
        $self->{ params }{ $key } = $val;
    }
}

=head2 output

This method takes no parameters and returns the final rendering result from
applying all arguments set by L<param> to the template.

=cut

sub output
{
    croak "Virtual method called. Template classes must override this";
}

=head2 _theme_file_path

Construct a path to a theme file from a filename passed in and the C<theme_dir>
and C<theme> specified at construction time. Returns C<undef> if the file does not
exist or is not readable.

=cut

sub _theme_file_path
{
    my ( $self, $filename ) = @_;

    # Construct path to template
    my $file =
      file( $self->{ theme_dir }, $self->{ theme }, $filename )->stringify;

    # Make sure the file exists
    ( -f $file and -r $file ) or return;
    return $file;
}

=head2 _theme_dir

Construct a path to the theme dir and check that it exists. Returns the
diretory on success, C<undef> otherwise.

=cut

sub _theme_dir
{
    my ($self) = @_;

    my $dir = dir( $self->{ theme_dir }, $self->{ theme } )->stringify;
    -d $dir or
      die
      "The theme '$self->{theme}' doesn't exist beneath '$self->{theme_dir}'!";
    return $dir;
}

sub _custom_funcs
{
    my ($self) = @_;

    my %custom_funcs;
    my $textdomain = 'chronicle2-theme';
    my $locale_dir = dir( $self->_theme_dir, 'locale' );
    ## no critic (Eval)
    eval("use Locale::TextDomain '$textdomain', '$locale_dir';");
    ## use critic
    if ( $@ or
         version->parse($Locale::TextDomain::VERSION) < version->parse('1.16') )
    {
        %custom_funcs = (
            N__ => sub {return $_[0]},
            __  => sub {return $_[0]},
            __n => sub {$_[2] > 1 ? $_[1] : $_[0]},
            __nx => sub {
                return
                  $_[2] > 1 ? _substargs( $_[1], splice( @_, 3 ) ) :
                  _substargs( $_[0], splice( @_, 3 ) );
            },
            __p  => sub {return $_[1]},
            __px => sub {return _substargs( $_[1], splice( @_, 2 ) )},
            __x  => sub {return _substargs( $_[0], splice( @_, 1 ) )},
                        );
        $custom_funcs{ __px } = $custom_funcs{ __nx };
        $custom_funcs{ __ }   = $custom_funcs{ N__ };
    }
    else
    {
        %custom_funcs = ( N__   => sub {N__(@_)},
                          __    => sub {__(@_)},
                          __n   => sub {__n(@_)},
                          __nx  => sub {__nx(@_)},
                          __npx => sub {__npx(@_)},
                          __x   => sub {__x(@_)},
                          __p   => sub {__p(@_)},
                          __px  => sub {__px(@_)},
                        );
        POSIX::setlocale( LC_MESSAGES, '' );
        Locale::Messages::bind_textdomain_filter( $textdomain,
                                                  \&Encode::decode_utf8 );
    }
    $custom_funcs{ strftime } = sub {
        my ( $format, $epoch ) = @_;
        return strftime( $format, localtime $epoch );
    };

    return \%custom_funcs;
}

sub _substargs
{
    my $s    = shift;
    my %args = @_;
    while ( my ( $key, $value ) = each %args )
    {
        $s =~ s/\{$key\}/$value/;
    }
    return $s;
}

1;
