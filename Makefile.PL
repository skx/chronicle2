
use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.30;

use File::ShareDir::Install;

#
#  Install our themes
#
install_share dist => 'themes';



my %WriteMakefileArgs = (
    NAME         => 'App::Chronicle',
    EXE_FILES    => ['bin/chronicle'],
    VERSION_FROM => 'bin/chronicle',
    PREREQ_PM    => {

        'DBI'                        => 0,
        'Date::Format'               => 0,
        'Date::Language'             => 0,
        'Date::Parse'                => 0,
        'Digest::MD5'                => 0,
        'File::Basename'             => 0,
        'File::Find'                 => 0,
        'File::Path'                 => 0,
        'File::ShareDir'             => 0,
        'Getopt::Long'               => 0,
        'HTML::Template'             => 0,
        'HTML::Element'              => 5,
        'Module::Pluggable::Ordered' => 0,
        'Path::Class'                => 0,
        'Pod::Usage'                 => 0,

        # optional formatters.
        'Text::Markdown'      => 0,
        'Text::MultiMarkdown' => 0,
        'Text::Textile'       => 0,
        'Unicode::Normalize'  => 0,
        'URI'                 => 0,
    },

    TEST_REQUIRES => {

        # solely for the test-suite.
        'HTML::Tree'          => 0,
        'Test::Exception'     => 0,
        'Test::More'          => 0,
        'Test::NoTabs'        => 0,
        'Test::Pod'           => 0,
        'Test::Pod::Coverage' => 0,
        'Test::Strict'        => 0,

    },


    BUILD_REQUIRES => { 'File::ShareDir::Install' => 0,
                        'Test::More'              => 0,
                        'Test::Pod'               => 0,
                        'Test::Strict'            => 0,
                        'Test::NoTabs'            => 0,
                      },

    ABSTRACT => 'A static blog-compiler with minimal dependencies.',
    AUTHOR   => 'Steve Kemp <steve@steve.org.uk>',
    LICENSE  => "perl",

    MIN_PERL_VERSION => '5.008',

    META_MERGE => {
                   resources => {
                       license    => 'http://dev.perl.org/licenses/',
                       homepage   => 'https://github.com/skx/chronicle2/',
                       bugtracker => 'https://github.com/skx/chronicle2/issues',
                       repository => 'https://github.com/skx/chronicle2.git',
                       GitMirror  => 'http://git.steve.org.uk/cpan/chronicle2',
                   },
                  },
);



unless ( eval {ExtUtils::MakeMaker->VERSION(6.56)} )
{
    my $br = delete $WriteMakefileArgs{ BUILD_REQUIRES };
    my $pp = $WriteMakefileArgs{ PREREQ_PM };
    for my $mod ( keys %$br )
    {
        if ( exists $pp->{ $mod } )
        {
            $pp->{ $mod } = $br->{ $mod } if $br->{ $mod } > $pp->{ $mod };
        }
        else
        {
            $pp->{ $mod } = $br->{ $mod };
        }
    }
}

delete $WriteMakefileArgs{ CONFIGURE_REQUIRES }
  unless eval {ExtUtils::MakeMaker->VERSION(6.52)};

WriteMakefile(%WriteMakefileArgs);



package MY;
use File::ShareDir::Install 'postamble';
