
* Homepage:
   * http://www.steve.org.uk/Software/chronicle/
* Git Repository:
   * http://github.com/skx/chronicle2
* Real World Use:
   * http://blog.steve.org.uk/


chronicle
---------

Chronicle is a tool which will convert a directory of simple text files into a static HTML weblog, (or blog if you prefer).

This repository contains a from-scratch rewrite of the Chronicle static blog compiler, which represents a significant upgrade in terms of both speed and flexibility.

The system is intentionally simple, but it does support:

* Template based output.
* Support for RSS feeds.
* Support for tagged entries.
* Optional support for comments.


This implementation is significantly faster at page generation than previous releases, primarily because posts are parsed and inserted into an SQLite database, rather than having each post read into RAM.

Once the blog posts have been populated in the SQLite database they are inserted into a series of templates, which ultimately generates the output.

> Although we assume you keep the SQLite database around it doesn't matter if you delete it.  The act of parsing all your entries is still a very quick process.


Installation
-------------

Clone the repository then install as you would any CPAN module:

    perl Makefile.PL
    make test
    su - make install




Blog Format
-----------

The blog format is very simple, and the following file is a sample:

    title: The title of my post
    date: 12 August 2007
    tags: foo, bar, baz

    The text of the actual entry goes here.

    However much there is of it.


The entry is prefixed by a small header, consisting of several pseudo-header fieilds. The header __MUST__ be separated from the body by at least one empty line.

Header values which are unknown are ignored, and no part of the header is included in the output which is generated.

The following header values are recognised:

* Title:
    * This holds the name of the post. ("Subject:" may be used as a synonym.) If neither "Title" or "Subject" are present the filename itself is used.
* Date:
    * The date this entry was created. If not present the creation time of the file is used.
* Tags:
    * If any tags are present they will be used to categorise the entry.



Simple Usage
------------

Assuming you have a directory containing a number of blog posts
you should be able to generate your blog like so:

    chronicle --input=path/to/input --output=/path/to/output \
       --theme=blog.steve.org.uk

This will read `path/to/input/*.txt` and generate the blog beneath
the directory `/path/to/output/` creating that directory if missing.

The SQLite database will be created at `~/blog.db`, and if it is
deleted it will be regenerated.

For more advanced usage please consult the help.

To user your own theme then copy one of the included ones and
use:

    chronicle --theme-dir=./themes --theme=local

This will ensure that theme-templates are read from `themes/local/`.


User-Visible Changes
--------------------

In an ideal would you should be able to migrate from Chronicle directly
to this codebase, as there are a lot of commonalities:

* Blog entries are are still read from `data/`.
* Blog entries are still built up of a header and the entry.
* Entries are still parsed in HTML, Markdown, and Textile formats.

However there are changes, and these largely relate to the templates,
along with the implementation differences.

The previous Chronicle codebase was comprised of a few different binaries,
the new has only the single driver `chronicle` and a collection of plugins.

The driver script parse arguments, and the blog posts, but the actual
generation of your site is entirely plugin-based.  The plugins are standard
Perl modules located beneath the `Chronicle::Plugin` namespace, and
although you don't need to know any of the details they can be ordered
thanks to the use of [Module::Pluggable::Ordered](http://search.cpan.org/perldoc?Module%3A%3APluggable%3A%3AOrdered) class.

The template changes are a little more signficant than I'd like, but
happily these changes largely consist of new locations for things,
and additional pages.


Unsupported Operations
----------------------

The following features are missing and unlikely to return:

* The inline calandar.


Extending
---------

As mentioned the core code is pretty minimal and all output functionality
is carried out by plugins.

The core will call the following methods if present in plugins:

* `on_db_create`
   * This is called if the SQLite database does not exist, and can be used to add new columns, or tables.

* `on_db_open`
   * This is called when the database is opened, and we use it to set memory/sync options.  It could be used to do more.

* `on_insert`
   * This method is invoked as a blog entry is read to disk before it is inserted into the database for the first time - or when the item on disk has been changed and the database must be refreshed.
   * This method is designed to handle Markdown/Textile conversion, etc.

* `on_initiate`
   * This is called prior to any processing, with a reference to the configuration options and the database handle used for storage.
   * This is a good place to call code that generates common snippets, or populates global-variables.

* `on_generate`
   * This is called to generate the actual output pages.  There is no logical difference between this method and `on_initiate` except that the former plugin methods are guaranteed to have been called prior to `on_generate` being invoked.
   * This is where pages are output.



Steve
--
