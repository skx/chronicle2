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

sub output {
    my $self = shift;
    my $htmpl = $self->{htmpl};
    $htmpl->param($_ => $self->{params}{$_}) for keys %{$self->{params}};
    return $htmpl->output;
}

1;

