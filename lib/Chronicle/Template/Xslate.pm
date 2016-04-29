package Chronicle::Template::Xslate;
use strict;
use warnings;
use parent 'Chronicle::Template::GenericXslate';

=head1 NAME

Chronicle::Template::Xslate - L<Text::Xslate> templates with Kolon syntax.

=head1 DESCRIPTION

This trivial class defines the two private methods C<_syntax> and C<_extension>
to specify processing details for L<Chronicle::Template::GenericXslate>

=head1 METHODS

=head2 _syntax

Return the syntax to use

=cut

sub _syntax {'Kolon'}

=head2 _extension

Return the template file extension

=cut

sub _extension {'tx'}

1;

