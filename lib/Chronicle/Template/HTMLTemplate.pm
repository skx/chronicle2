package Chronicle::Template::HTMLTemplate;

use strict;
use warnings;
use Chronicle::Template;
use parent 'Chronicle::Template';
use HTML::Template;
use Path::Class;

my %DEFAULT_OPTIONS = (
    open_mode => '<:encoding(UTF-8)',
    die_on_bad_params => 0,
    loop_context_vars => 1,
    global_vars       => 1,
);

=head1 NAME

Chronicle::Template::HTMLTemplate - L<HTML::Template> based templates

=head1 DESCRIPTION

This class contains all the functionality required for templates based on
L<HTML::Template>.

=head1 METHODS

=head2 new

See L<Chronicle::Template> and C<%DEFAULT_OPTIONS> defined above.

=cut

sub new {
    my $class = shift;
    my %options = @_;
    my $self = $class->SUPER::new(@_);
    bless $self, $class;

    if(exists $options{tmpl_string}) {
        $options{scalarref} = \do{delete $options{tmpl_string}};
    } else {
        my $filename = (delete $options{tmpl_file}) . ".tmpl";
        $self->_theme_file_path($filename) or return;
        $options{filename} = $filename;
    }

    $self->{htmpl} = HTML::Template->new(
        %DEFAULT_OPTIONS,
        %options,
        path => [ $self->_theme_dir ],
    );

    return $self;
}

=head2 output

See L<Chronicle::Template>

=cut

sub output {
    my $self = shift;
    my $htmpl = $self->{htmpl};
    $htmpl->param($_ => $self->{params}{$_}) for keys %{$self->{params}};
    return $htmpl->output;
}

1;

