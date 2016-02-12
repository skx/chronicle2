
=head1 NAME

Chronicle::Plugin::Tidy - Attempt to fix malformed HTML.

=head1 DESCRIPTION

This plugin is designed to prevent malformed HTML from being generated.

It does that by using the L<HTML::TreeBuilder> module to parse the
HTML that has been inserted into the SQLite database and then rewalks
the tree to try to fix broken entries.

As an example the following bogus HTML will be fixed:

=for example begin

    <p>This is a line of text.</P>

=for example end

Similarly tags that are not closed will be fixed up.

=cut

=head1 METHODS

Now follows documentation on the available methods.

=cut

package Chronicle::Plugin::Tidy;


use strict;
use warnings;


our $VERSION = "5.1.3";


=head2 on_insert

The C<on_insert> method is automatically invoked when a new blog post
must be inserted into the SQLite database, that might be because a post
is new, or because it has been updated.

The method is designed to return an updated blog-post structure,
after performing any massaging required.  If the method returns undef
then the post is not inserted.

Here we walk the HTML entry, which might have been written by hand
or which might have been created via L<Chronicle::Plugin::Markdown>,
or some other plugin, and try to ensure it is well-formed.

=cut

sub on_insert
{
    my ( $self, %args ) = (@_);

    my $conf = $args{ 'config' };
    my $data = $args{ 'data' };
    my $html = $data->{ 'body' };

    #
    #  Load the HTML::TreeBuilder module, if present.
    #
    foreach my $mod (qw! HTML::TreeBuilder !)
    {
        my $test = "use $mod;";
        ## no critic (Eval)
        eval($test);
        ## use critic

        if ($@)
        {
            return ($data);
        }
    }

    my $tree = HTML::TreeBuilder->new();
    $tree->ignore_unknown(0);
    $tree->ignore_ignorable_whitespace(0);
    $tree->no_space_compacting(1);
    $tree->p_strict(1);
    $tree->store_comments(0);
    $tree->store_declarations(0);
    $tree->store_pis(0);
    $tree->parse_content($html);

    my $txt;

    my @nodes = $tree->disembowel();
    foreach my $node (@nodes)
    {
        if ( ref $node )
        {
            $txt .= $node->as_HTML( undef, '', {} );
            chomp $txt;
            $node->delete();
        }
        else
        {
            $txt .= $node;
        }
    }
    $tree->delete();

    #
    #  Update the body and return the updated post.
    #
    $data->{ 'body' } = $txt;
    return ($data);
}


=head2 _order

We want this plugin to be called I<after> the other plugins which
filter new entries - so that we can fix their broken HTML.

This method is present such that L<Module::Pluggable::Ordered> can
order our plugins.

=cut

sub _order
{
    return 999;
}


1;


=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version,
or

b) the Perl "Artistic License".

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut
