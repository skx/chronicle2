Themes
------

Themes in Chronicle are simple collections of files which are populated
and rendered via the
[HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) or
[Text::Xslate](https://metacpan.org/pod/Text::Xslate) module.

To create a new theme the simplest approach is to take an existing theme and modify it.  Once you have a local theme you can cause it to be used like so:

    chronicle --theme-dir=./themes --theme=local

This will ensure that your theme-templates are read from `./themes/local/`.

If you would like to use a theme based on `Text::Xslate`, you have to specify
`Xslate` or `XslateTT` as an argument to `--theme-engine` for the Kolon and
TTerse syntax respectively.

Theme Files
-----------

Each theme should contain the following files:

* archive.tmpl
   * This is used to build /archive/$year/$mon
* archive_index.tmpl
   * Used to build /archive/ - A list of previous pages
* tag.tmpl
   * This is used to build the page /tags/$name/ - The list of posts with the given tag.
* tag_index.tmpl
   * Used to build the page /tags/ - A list of previous tags
* entry.tmpl
   * This is used to write out the individual blog posts.
* index.tmpl
   * This is used to build the front-page of your site.
* index.rss
   * This is used to build the RSS-feed of your site.

Beyond that you can move common code to "include files", which can be inserted via:

    <!-- tmpl_include name='common.inc' -->

The supplied themes already make use of this facility to avoid repeating
common look and feel items.

Non-`HTML::Template` themes use the file extension `.tx` for Xslate/Kolon and
`.ttx` for Xslate/TTerse.

Localization
------------

`Xslate` and `XslateTT` templates support GNU libintl (AKA "the gettext
package") for localization so you can easily translate a template's boilerplate
into another language and use a template for different languages without editing
it. The way it works is via custom template functions, so you can replace e.g.
the following code

    <h1>[% title %]</h1>
    [% body %]
    <p>Published on [% date %],
    [% ncmts] comment[% IF ncmts > 1 %]s[% END %]</p>

with this

    <h1>[% __(title) %]</h1>
    [% body %]
    <p>[% __x('Published on {date}', date => date) %],
    __nx('1 comment', '{cmts} comments', ncmts, cmts => ncmts) %]</p>

This will

1. Allow to simply translate "Title" without changing the template
2. Let you translate "Published on {date}" even to languages that may want the
date at some other position in the sentence
3. Select the correct singular/plural version for the comments even for
languages like Chinese that have no grammatical plurals, like Polish or Arabic
that have more than a single plural, or like French that have simply different rules
what to use with zeros.

The translation happens via standard \*.po/\*.mo files that can simply be created
in a text editor but for which there is also a wealth of translation tools (poedit etc.)
available. These files must always be called `chronicle2-theme.{po,mo}` and
live in a directory called `<theme>/locale/<locale>/LC_MESSAGES/` where
`<theme>` is the current theme's base directory and `<locale>` is the current
value of the `$LANGUAGE` variable, e.g. `de_DE.UTF-8`. See the [towiski
theme](https://github.com/mbethke/chronicle_towiski) for a simple example.
Note that only UTF-8 is supported as encoding for these files. Don't bother with
anything else in the 2010s.

If the user doesn't have `Locale::TextDomain` installed, fallback functions
simply pass through the arguments provided in the template.

The following functions are available and all borrowed from
[`Locale::TextDomain`](https://metacpan.org/pod/Locale::TextDomain); see there
for detailed documentation on what they do:

* `__()`
* `__n()`
* `__x()`
* `__nx()`
* `__npx()`
* `__p()`
* `__px()`
* `N__()`

Custom Functions
----------------

On top of the above functions to support l10n, Xslate templates also have an
`strftime` function that works as documented in the `POSIX` module and can be
used to construct custom (non-localized) dates on the fly in templates.

Static Resources
----------------

If your theme  directory contains a `static/` subdirectory then the contents of that directory will be copied over to your generated site.

This is designed to allow you to include your CSS files, images, and other static resources that are used by your theme.


