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

Static Resources
----------------

If your theme  directory contains a `static/` subdirectory then the contents of that directory will be copied over to your generated site.

This is designed to allow you to include your CSS files, images, and other static resources that are used by your theme.


