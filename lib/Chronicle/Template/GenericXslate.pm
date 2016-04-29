package Chronicle::Template::GenericXslate;

use strict;
use warnings;
use Chronicle::Template;
use parent 'Chronicle::Template';
use Path::Class;

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

    my $test = "use Text::Xslate;";

    ## no critic (Eval)
    eval($test);
    ## use critic

    if ($@)
    {
        die "Failed to load Text::Xslate module - $!";
    }

    my %options = @_;
    my $self    = $class->SUPER::new(@_);
    bless $self, $class;

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
        syntax => $self->_syntax, );
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

1;
