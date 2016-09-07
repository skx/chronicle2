package Chronicle::Template::TT;

use strict;
use warnings;
use Template;
use Template::Stash;
use Encode;
use Path::Class;
use POSIX qw/ :locale_h strftime /;
use parent 'Chronicle::Template';

=head1 NAME

Chronicle::Template::TT - L<Template> Toolkit based templates

=head1 DESCRIPTION

This class contains all the functionality required for templates based on
L<Template> Toolkit.

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

    ## no critic (Eval)
    eval('use Template;');
    ## use critic

    if ($@)
    {
        die "Failed to load Template module - $!\n" .
          "Debian users can fix this by installing libtemplate-perl";
    }


    if ( $options{ tmpl_string } )
    {
        $self->{ render } = sub {
            my $out;
            $self->{ tt }
              ->process( \$options{ tmpl_string }, $self->{ params }, \$out );
            return $out;
        };
    }
    else
    {
        my $filename = sprintf "%s.%s", $options{ tmpl_file },
          $self->_extension;
        $self->_theme_file_path($filename) or return;
        $self->{ render } = sub {
            my $out;
            $self->{ tt }->process( $filename, $self->{ params }, \$out );
            return $out;
        };
    }

    $self->{ tt } = Template->new(
            INCLUDE_PATH =>
              join( ':',
                $self->_theme_dir, dir( $self->_theme_dir, 'inc' )->stringify ),
            INTERPOLATE => 1,
            STASH       => $self->_create_stash,
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
        $s =~ s/\{$key\}/$value/;
    }
    return $s;
}

sub _create_stash
{
    my ($self) = @_;
    my $stash  = Template::Stash->new;
    my $funcs  = $self->_custom_funcs;
    $stash->set( "loc$_", $funcs->{ $_ } ) for qw/ N__ __ __n __p /;
    $stash->set( "loc__nx",
                 sub {$funcs->{ __nx }->( @_[0 .. 2], %{ $_[3] } )} );
    $stash->set( "loc__px",
                 sub {$funcs->{ __px }->( @_[0 .. 1], %{ $_[2] } )} );
    $stash->set( "loc__x", sub {$funcs->{ __x }->( $_[0], %{ $_[1] } )} );
    return $stash;
}

1;
