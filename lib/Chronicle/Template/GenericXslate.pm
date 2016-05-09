package Chronicle::Template::GenericXslate;

use strict;
use warnings;
use Chronicle::Template;
use parent 'Chronicle::Template';
use Path::Class;
use POSIX qw/ :locale_h /;

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
    my $class = shift;
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

    my $localize;
    eval('use Locale::TextDomain qw( chronicle2-theme '.
        dir($self->{theme_dir}, $self->{theme}, 'locale')  . ');'
    );
    if($@) {
        $localize = {
            N__ => sub { return @_; },
            __n => sub { $_[2] > 1 ? $_[1] : $_[0] }, 
            __nx => sub {
                $_[2] > 1 ?
                _substargs($_[1], splice(@_, 3)) :
                _substargs($_[0], splice(@_, 3))
            },
            __p => sub { return $_[1] },
            __px => sub { _substargs($_[1], splice(@_, 3)) },
            __x => sub { _substargs($_[0], splice(@_, 2)) },
        };
        $localize->{__px} = $localize->{__nx};
        $localize->{__} = $localize->{__N};
        die "Not localized\n"; # FIXME
    } else {
        $localize = {
            __ => sub { __(@_) },
            N__ => sub { N__(@_) },
            __n => sub { __n(@_) }, 
            __nx => sub { __nx(@_) },
            __npx => sub { __npx(@_) },
            __x => sub { __x(@_) },
            __p => sub { __p(@_) },
            __px => sub { __px(@_) },
        };
        POSIX::setlocale(LC_ALL, '');
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
        syntax => $self->_syntax,
        function => $localize,
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

sub _localize {
    return ngettext(@_);
}

sub _localize_dummy { return $_[0] }

sub _substargs {
    my $s = shift;
    my %args = @_;
    while(my ($key, $value) = each %args) {
        $s =~ s/$key/$value/;
    }
    return $s;
}

1;
