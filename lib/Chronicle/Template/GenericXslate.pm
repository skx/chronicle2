package Chronicle::Template::GenericXslate;

use strict;
use warnings;
use Chronicle::Template;
use Encode;
use Path::Class;
use POSIX qw/ :locale_h strftime /;
use parent 'Chronicle::Template';

=head1 NAME

Chronicle::Template::GenericXslate - Base class for Xslate based templates

=head1 DESCRIPTION

This class contains all the functionality required for templates based on
L<Text::Xslate> but is not intended to be used directly. Its subclasses must
define the methods C<_extension> and C<_syntax>; see
C<Chronicle::Template::Xslate*> for trivial examples.

=head1 METHODS

=head2 new

See L<Chronicle::Template>

=cut

sub new
{
    my $class   = shift;
    my %options = @_;
    my $self    = $class->SUPER::new(@_);
    bless $self, $class;

    my $test = "use Text::Xslate;";

    ## no critic (Eval)
    eval($test);
    ## use critic

    if ($@)
    {
        die "Failed to load Text::Xslate module - $!";
    }

    my %xslate_functions;
    my $textdomain = 'chronicle2-theme';
    my $locale_dir = dir( $self->{ theme_dir }, $self->{ theme }, 'locale' );
    ## no critic (Eval)
    eval("use Locale::TextDomain '$textdomain', '$locale_dir';");
    ## use critic
    if ($@ or version->parse($Locale::TextDomain::VERSION) < version->parse('1.16'))
    {
        %xslate_functions = (
            N__ => sub {return @_},
            __  => sub {return @_},
            __n => sub {$_[2] > 1 ? $_[1] : $_[0]},
            __nx => sub {
                $_[2] > 1 ? _substargs( $_[1], splice( @_, 3 ) ) :
                  _substargs( $_[0], splice( @_, 3 )
                            );
            },
            __p  => sub {return $_[1]},
            __px => sub {_substargs( $_[1], splice( @_, 3 ) )},
            __x  => sub {_substargs( $_[0], splice( @_, 2 ) )},
        );
        $xslate_functions{ __px } = $xslate_functions{ __nx };
        $xslate_functions{ __ }   = $xslate_functions{ __N };
    }
    else
    {
        %xslate_functions = ( N__   => \&N__,
                              __    => \&__,
                              __n   => \&__n,
                              __nx  => \&__nx,
                              __npx => \&__npx,
                              __x   => \&__x,
                              __p   => \&__p,
                              __px  => \&__px,
                            );
        POSIX::setlocale( LC_MESSAGES, '' );
        Locale::Messages::bind_textdomain_filter( $textdomain,
                                                  \&Encode::decode_utf8 );
    }

    if ( $options{ tmpl_string } )
    {
        $self->{ render } = sub {
            return $self->{ xslate }
              ->render_string( $options{ tmpl_string }, $self->{ params } );
        };
    }
    else
    {
        my $filename = sprintf "%s.%s", $options{ tmpl_file },
          $self->_extension;
        $self->_theme_file_path($filename) or return;
        $self->{ render } = sub {
            return $self->{ xslate }->render( $filename, $self->{ params } );
        };
    }

    $self->{ xslate } =
      Text::Xslate->new(
        path => [$self->_theme_dir, dir( $self->_theme_dir, 'inc' )->stringify],
        syntax   => $self->_syntax,
        function => {
            %xslate_functions,
            strftime => sub {
                my ($format, $epoch) = @_;
                return strftime($format, localtime $epoch);
            },
        },
                       );
    return $self;
}

=head2 output

See L<Chronicle::Template>

=cut

sub output
{
    my $self = shift;
    return $self->{ render }->( $self->{ params } );
}

sub _substargs
{
    my $s    = shift;
    my %args = @_;
    while ( my ( $key, $value ) = each %args )
    {
        $s =~ s/$key/$value/;
    }
    return $s;
}

1;
