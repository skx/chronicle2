package Chronicle::Template::Xslate;

use strict;
use warnings;
use Chronicle::Template;
use parent 'Chronicle::Template';
use Text::Xslate;
use Path::Class;

sub new {
    my $class = shift;
    my %options = @_;
    my $self = $class->SUPER::new(@_);
    bless $self, $class;

    if($options{tmpl_string}) {
        $self->{render} = sub {
            return $self->{xslate}->render_string($options{tmpl_string}, $self->{params});
        };
    } else {
        my $filename = "$options{tmpl_file}.tx";
        $self->_theme_file_path($filename) or return;
        $self->{render} = sub {
            return $self->{xslate}->render($filename, $self->{params});
        };
    }

    $self->{xslate} = Text::Xslate->new(
        path => [
            $self->_theme_dir,
            dir($self->_theme_dir, 'inc')->stringify
        ],
        syntax => 'TTerse',
    );
    return $self;
}

sub output {
    my $self = shift;
    return $self->{render}->($self->{params});
}

1;

